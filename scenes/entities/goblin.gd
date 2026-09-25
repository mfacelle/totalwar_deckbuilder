extends CharacterBody2D
# need to figure out inheritance from a base "entity" object.
# a lot of this class is general to all entities, so it can probably
# become a base class eventually

# basic state, for updating entity
enum State
{
    IDLE,
    MOVE,
    ATTACK,
    DEAD,
    STUCK
}

# commands that influence behavior of entity
enum Command
{
    ATTACK,
    DEFEND,
    HOLD,
    RETREAT
}

# type of entity, with values matching collision layer ID they will use
enum EntityType
{
    FRIENDLY = 5,
    ENEMY = 6
}

@export_category("Stats")
## speed, in pixels/sec
@export var speed: int
## faction that this entity belongs to (determines what damage collision layers to use)
@export var entity_type: EntityType = EntityType.FRIENDLY
## how much health this entity can have
@export var max_health: int
## range for valid attacks, in pixels
@export var attack_range: int
## attack speec, in seconds
@export var attack_speed: float
## delay between attacks, in seconds
@export var attack_delay: float
## how much damage this entity's attacks do
@export var attack_damage: int
## name of group to use when looking for opponents
@export var enemy_group_name: String
## threshold for minimum movement for detecting stuck state
@export var min_movement_speed: float
## how long to wait, in seconds, when stuck, before re-attempting movement
@export var stuck_delay: float

var state: State = State.IDLE
var command: Command = Command.ATTACK
var target_enemy: Node2D = null
var attack_ready: bool = true
var health: int = max_health
var stuck_timer: float = 0
#var last_position: Vector2

# references to nodes in this object
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var hurt_box: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox
@onready var sprite = $Sprite2D
@onready var flash_timer: SceneTreeTimer


func _ready() -> void:
    # only enable animations when game is active (so editor doesn't keep them running)
    anim_tree.set_active(true)
    
    # set layer used for damage collisions affecting this object
    # TODO this is not great. didn't want to have two separate variable for hit/hurt box types, though
    if entity_type == EntityType.FRIENDLY:
        hurt_box.set_collision_layer_value(EntityType.FRIENDLY, true)
        hit_box.set_collision_mask_value(EntityType.ENEMY, true)
    else:
        hurt_box.set_collision_layer_value(EntityType.ENEMY, true)
        hit_box.set_collision_mask_value(EntityType.FRIENDLY, true)
    
    # set values for parameters other than default
    health = max_health
    state = State.IDLE
    command = Command.ATTACK
    #last_position = global_position
    
    # wait a frame for navigation to be set up
    await get_tree().physics_frame


func _physics_process(delta: float) -> void:
    # TODO will also need to handle commands along with state.
    # refactor this into a more proper state machine
    
    # do nothing here if dead or attacking
    if state == State.DEAD or state == State.ATTACK:
        return
    
    # if target exists and within range, attack
    # if target exists and not in range, move
    # if target does not exist, find new target. if not, idle
    
    if target_enemy:
        # if enemy exists and is within range, attempt to attack it
        if global_position.distance_to(target_enemy.global_position) < attack_range:
            if attack_ready:
                attack()
        else: # move towards it
            move(delta)
    else: # no current target, find a new enemy
        target_enemy = find_closest_enemy()
        if target_enemy:
            print(name, " found target=", target_enemy.name, "; pos=", target_enemy.global_position)
        else: # set to idle if no target found
            state = State.IDLE
            velocity = Vector2.ZERO
    
    # ensure correct animation state is set
    update_animation()


func update_animation() -> void:
    match state:
        State.IDLE, State.STUCK:
            anim_playback.travel("idle")
        State.MOVE:
            anim_playback.travel("move")
        State.ATTACK:
            anim_playback.travel("attack")
        _:
            anim_playback.travel("idle")


# consider making this a utility function in a separate script (maybe even C++)
# notes on this:
# - use nav mesh to find closest, not just straight distance
# - consider enemy types or something, eventually
# - use "target points" (separate function?) 
func find_closest_enemy() -> Node2D:
    # TODO consider adding some kind of delay when searching for enemies
    var enemies = get_tree().get_nodes_in_group(enemy_group_name)
    var closest_enemy: Node2D = null
    var shortest_distance: float = INF
    
    # TODO does this distance take into account the nav mesh? probably not...
    # definitely need to include that somewhere here
    for enemy in enemies:
        if enemy == self:
            continue
        var distance = global_position.distance_to(enemy.global_position)
        #print(name, "(pos=", global_position, "); found ", enemy.name, "; pos=", enemy.global_position, "; distance=", distance)
        if distance < shortest_distance:
            shortest_distance = distance
            closest_enemy = enemy
            
    return closest_enemy


func move(delta: float) -> void:
    if state == State.STUCK and stuck_timer < stuck_delay:
        #velocity = Vector2.ZERO
        stuck_timer += delta
        return
    
    # ensure stuck_timer is cleared
    stuck_timer = 0
    state = State.MOVE
    
    # eventually, we want to be able to move towards things other than target enemies.
    # for now, this is fine
    if target_enemy:
        nav_agent.target_position = target_enemy.global_position
    var next_path_pos: Vector2 = nav_agent.get_next_path_position()
    var new_velocity: Vector2 = global_position.direction_to(next_path_pos) * speed
    
    # set parameters for blendspace move/idle animations
    anim_tree.set("parameters/move/BlendSpace2D/blend_position", new_velocity.normalized())
    anim_tree.set("parameters/idle/BlendSpace2D/blend_position", new_velocity.normalized())
    
    # TODO notes about this.  
    # - going to disable, because it's fine if they're just running in place for now.
    #   however... it does sometimes cause weird movement if there's a bunch of entities.
    #   but maybe not a huge deal, because this is starting off with individual creatures, not big units
    # - object appears to still have a velocity value, even when it's not moving
    # - this is due to avoidance still setting velocity, but overriding actual movement or something
    # - also need to be able to handle initially-not-moving state, or trying to restart moving after being stuck
    #var distance_moved = global_position.distance_to(last_position)
    #if distance_moved < min_movement_speed * delta and new_velocity.length() > 0.0:
        #print(name, " stuck at ", Time.get_time_string_from_system())
        #state = State.STUCK
        #velocity = Vector2.ZERO

    #print(name, "   new velocity=", new_velocity.length())
    #print(name, "   actual velocity=", velocity.length())
        
    if nav_agent.avoidance_enabled:
        nav_agent.set_velocity(new_velocity)
    else:
        _on_navigation_agent_2d_velocity_computed(new_velocity)
    
    #last_position = global_position
    
    # only call move from this function
    move_and_slide()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
    if state != State.STUCK:
        velocity = safe_velocity
    # not calling move_and_slide from this function, because this callback is hit from various places


func attack() -> void:
    # do nothing if already attacking
    if state == State.ATTACK:
        return
    
    # set state to attack and disable ready flag, for next attack
    state = State.ATTACK
    attack_ready = false
    
    # halt any movement
    velocity = Vector2.ZERO
    nav_agent.set_velocity(Vector2.ZERO)
    
    # get direction to target and set animation params
    var attack_dir = global_position.direction_to(target_enemy.global_position).normalized()
    #print(name, " attacking ", target_enemy.name, " dir=", attack_dir)
    anim_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir.normalized())
    update_animation()
    
    # return to idle after attack finishes
    await get_tree().create_timer(attack_speed).timeout
    state = State.IDLE
    
    # wait to set flag for next attack
    await get_tree().create_timer(attack_delay).timeout
    attack_ready = true
    

func take_damage(damage: int) -> void:
    print(name, " about to take damage. health=", health)
    health -= damage
    print(name, " took ", damage, " damage. health=", health)
    if health <= 0:
        die()
    
    # Color(R, G, B, Alpha) - Setting green and blue to 0 leaves only pure red tint
    sprite.modulate = Color(1, 0, 0, 1) 
    
    # create simple timer to modulate sprite back to normal
    get_tree().create_timer(0.2).timeout.connect(func():
        sprite.modulate = Color(1, 1, 1, 1)
    )


func _on_hit_box_area_entered(area: Area2D) -> void:
    print(name, " about to deal damage. damage=", attack_damage, "; ownder=", area.owner.name, "; area=", area.name)
    area.owner.take_damage(attack_damage)


func die() -> void:
    # TODO play animation
    queue_free()
    # TODO send some kind of notification to all units that have this object as a target,
    # so they can set a delay before finding the next target
