class_name Unit
extends CharacterBody2D
# base unit object, handles simple commands, states, movement.
# create derived classes (figure out how) to implement specific logic for units

# emitted for other units to listen to
signal unit_died(unit: Unit)


@export_category("Stats")
## ID for this unit, for retrieving stats from config
@export var unit_id: UnitData.UnitId
## faction that this entity belongs to (determines what damage collision layers to use)
@export var entity_type: UnitTypes.EntityType = UnitTypes.EntityType.FRIENDLY
## name of group to use when looking for opponents
@export var enemy_group_name: String
## threshold for minimum movement for detecting stuck state
@export var min_movement_speed: float = 1.0
## how long to wait, in seconds, when stuck, before re-attempting movement
@export var stuck_delay: float = 1.0
## how often, in seconds, to periodically search for a closer enemy
@export var target_update_delay: float = 1.0
## size of enemy search area (TODO eventually make this part of UnitData)
@export var enemy_search_radius: int = 30

@export_category("Node References")
@export var anim_tree: AnimationTree
@export var nav_agent: NavigationAgent2D
@export var hurt_box: Area2D
@export var hit_box: Area2D
@export var sprite: Sprite2D
@export var click_area: Area2D
@export var enemy_search_area_scene: PackedScene

@export_category("Resources")
@export var highlight_shader: ShaderMaterial

@export_category("Animations")
## how long to fade in red hurt animation
@export var hurt_fadein_duration: float = 0.05
## how long to fade out red hurt animation
@export var hurt_fadeout_duration: float = 0.25
## color modulation for bad placement animation
@export var hurt_color: Color = Color(1, 0, 0, 1)
## standard color modulation
@export var normal_color: Color = Color(1, 1, 1, 1)

## data for this unit, for setting stats
@onready var unit_data: UnitData = UnitDataManager.units[unit_id]
@onready var anim_playback: AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]

# components - start off as null, since some have constructor args
var health_component: HealthComponent = null
var click_component: ClickableComponent = null
var nearby_enemy_search_area: NearbyEnemySearchAreaComponent = null

## list of nearby enemies to search through
var nearby_enemies: Array[Unit]

# params and attributes
var state: UnitTypes.State = UnitTypes.State.IDLE
var command: UnitTypes.Command = UnitTypes.Command.ATTACK
var target_enemy: Unit = null
var attack_ready: bool = true
var stuck_timer: float = 0
var target_update_timer: float = 0
var tween: Tween
#var last_position: Vector2


func _ready() -> void:
    # only enable animations when game is active (so editor doesn't keep them running)
    anim_tree.set_active(true)
    
    set_up_areas_and_collision()
    
    # set up health component and add as child node (for better debugging)
    health_component = HealthComponent.new(unit_data.max_health)
    health_component.health_changed.connect(on_health_changed)
    health_component.died.connect(on_die)
    add_child(health_component)
    
    # set up initial state and position
    state = UnitTypes.State.IDLE
    command = UnitTypes.Command.ATTACK
    #last_position = global_position
    
    # start target search timer partially complete, so initial wait isn't as long
    target_update_timer = target_update_delay / 2.0
    
    # wait a frame for navigation to be set up
    await get_tree().physics_frame


## sets layers and masks for collision, as well as setting up clickable
## and enemy search areas
func set_up_areas_and_collision() -> void:
    # set up area 2d components and nodes to properly handle collision layers
    click_component = ClickableComponent.new(click_area)
    
    var enemy_type: UnitTypes.EntityType = UnitTypes.EntityType.ENEMY
    
    # set layer used for damage collisions affecting this object.
    # also ensure only friendly units can be selected
    if entity_type == UnitTypes.EntityType.FRIENDLY:
        hurt_box.set_collision_layer_value(UnitTypes.EntityType.FRIENDLY, true)
        hit_box.set_collision_mask_value(UnitTypes.EntityType.ENEMY, true)
        enemy_type = UnitTypes.EntityType.ENEMY
        click_component.clicked_on.connect(_on_click)
        click_component.hover_start.connect(_on_hover_start)
        click_component.hover_end.connect(_on_hover_end)
    else:
        hurt_box.set_collision_layer_value(UnitTypes.EntityType.ENEMY, true)
        hit_box.set_collision_mask_value(UnitTypes.EntityType.FRIENDLY, true)
        enemy_type = UnitTypes.EntityType.FRIENDLY
        click_area.input_pickable = false
    
    hit_box.area_entered.connect(_on_hit_box_area_entered)
    
    # set up search area for nearby enemies
    nearby_enemy_search_area = enemy_search_area_scene.instantiate() as NearbyEnemySearchAreaComponent
    nearby_enemy_search_area.enemy_type = enemy_type
    nearby_enemy_search_area.search_radius = enemy_search_radius
    nearby_enemy_search_area.enemy_entered.connect(_on_enemy_entered_search_area)
    nearby_enemy_search_area.enemy_exited.connect(_on_enemy_exited_search_area)
    add_child(nearby_enemy_search_area)


## processes various unit states
## TODO would be better to refactor into proper state machine soon
func _physics_process(delta: float) -> void:
    # TODO will also need to handle commands along with UnitTypes.State.
    # refactor this into a more proper state machine
    
    # do nothing here if dead or attacking
    if state == UnitTypes.State.DEAD or state == UnitTypes.State.ATTACK:
        return
    
    # if target exists and within range, attack
    # if target exists and not in range, move
    # if target does not exist, find new target. if not, idle
    
    # update timer for checking for new targets
    # TODO may want to ignore this if actively attacking?
    target_update_timer += delta
    
    if target_enemy:
        # if enemy exists and is within range, attempt to attack it
        if global_position.distance_to(target_enemy.global_position) < unit_data.attack_range:
            if attack_ready:
                attack()
        else: # move towards it
            # TODO need to periodically check for a different enemy, in case there is now a closer one
            # this logic may change depend on type of npc, but this should be simple enough for base class
            move(delta)
    
    # try to find a new, closer, target
    if target_update_timer >= target_update_delay:
        target_update_timer = 0
        target_enemy = find_closest_enemy()
        if not target_enemy: # set to idle if no target found
            state = UnitTypes.State.IDLE
            velocity = Vector2.ZERO
    
    # ensure correct animation state is set
    update_animation()


func update_animation() -> void:
    match state:
        UnitTypes.State.IDLE, UnitTypes.State.STUCK:
            anim_playback.travel("idle")
        UnitTypes.State.MOVE:
            anim_playback.travel("move")
        UnitTypes.State.ATTACK:
            anim_playback.travel("attack")
        UnitTypes.State.DEAD:
            anim_playback.travel("die")
        _:
            anim_playback.travel("idle")


# consider making this a utility function in a separate script (maybe even C++)
# TODO notes on this:
# - use nav mesh to find closest, not just straight distance
# - use "target points"
# - consider moving into separate component
func find_closest_enemy() -> Unit:
    var closest_enemy: Unit = null
    var shortest_distance: float = INF
    
    # use nearby enemies, if any exist
    # TODO want to ignore all enemies, unless "rampage" mode
    var enemy_list: Array[Unit]
    if nearby_enemies.is_empty():
        # TODO this feels clunky... but need to get enemies as Unit types manually
        var enemy_nodes: Array[Node] = get_tree().get_nodes_in_group(enemy_group_name)
        for enemy_node in enemy_nodes:
            var enemy_unit: Unit = enemy_node as Unit
            enemy_list.append(enemy_unit)
    else:
        enemy_list = nearby_enemies
    
    # TODO distance needs to account for nav mesh
    for enemy in enemy_list:
        if enemy == self:
            continue
        var distance = global_position.distance_to(enemy.global_position)
        if distance < shortest_distance:
            shortest_distance = distance
            closest_enemy = enemy
            
    return closest_enemy


func move(delta: float) -> void:
    # if marked as stuck, dont process any movements for a bit.
    # note: this is currently disabled and won't happen
    if state == UnitTypes.State.STUCK and stuck_timer < stuck_delay:
        #velocity = Vector2.ZERO
        stuck_timer += delta
        return
    
    # ensure stuck_timer is cleared
    stuck_timer = 0
    state = UnitTypes.State.MOVE
    
    # eventually, we want to be able to move towards things other than target enemies.
    # for now, this is fine
    if target_enemy:
        nav_agent.target_position = target_enemy.global_position
    var next_path_pos: Vector2 = nav_agent.get_next_path_position()
    var new_velocity: Vector2 = global_position.direction_to(next_path_pos) * unit_data.speed
    
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
        #state = UnitTypes.State.STUCK
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
    if state != UnitTypes.State.STUCK:
        velocity = safe_velocity
    # not calling move_and_slide from this function, because this callback is hit from various places


func attack() -> void:
    # do nothing if already attacking
    if state == UnitTypes.State.ATTACK:
        return
    
    # set state to attack and disable ready flag, for next attack
    state = UnitTypes.State.ATTACK
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
    # TODO or register for a callback via the animation complete!
    await get_tree().create_timer(unit_data.attack_speed).timeout
    # TODO need better state transition logic
    if state != UnitTypes.State.DEAD:
        state = UnitTypes.State.IDLE
    
    # wait to set flag for next attack
    await get_tree().create_timer(unit_data.attack_delay).timeout
    attack_ready = true


## apply damage to whoever was hit by this unit's hit box
func _on_hit_box_area_entered(area: Area2D) -> void:
    area.owner.take_damage(unit_data.attack_damage)


## take damage, applying it to the health component
func take_damage(amount: int) -> void:
    health_component.damage(amount)


## if health dropped, tween to/from a red color
## TODO tween to green for healing?
func on_health_changed(_old_value: int, _new_value: int) -> void:
    if _new_value > 0 && _new_value < _old_value:
        if tween and tween.is_valid():
            tween.kill()
        tween = create_tween()
        tween.set_ease(Tween.EASE_OUT)
        tween.set_trans(Tween.TRANS_CIRC)
        tween.tween_property(sprite, "modulate", hurt_color, hurt_fadein_duration)
        tween.tween_property(sprite, "modulate", normal_color, hurt_fadeout_duration)


## play die animation and update state
func on_die() -> void:
    print(name, " died!")
    state = UnitTypes.State.DEAD
    
    # make unit not monitorable, and stop searching for enemies
    hurt_box.monitorable = false
    nearby_enemy_search_area.monitoring = false
    
    unit_died.emit(self as Unit)
    
    update_animation()


## delete this unit when die completed
func _on_die_animation_finished():
    queue_free()


## handle logic for when this unit is clicked on
## TODO implement this
func _on_click() -> void:
    # TODO need to check for proper battle state here as well,
    # meaning we need to listen for state changes on all units...
    # TODO or maybe make some kind of unit manager node that handles state info?
    print(name, " clicked on")

## highlight sprite on mouse hover
func _on_hover_start() -> void:
    sprite.material = highlight_shader
    # TODO check for proper battle state
    # TODO ad tween to fade in/out?
    pass

## return to normal when mouse no longer hovers
func _on_hover_end() -> void:
    sprite.material = null
    # TODO check for proper battle state
    # TODO ad tween to fade in/out?
    pass


## add to list of nearby enemies
func _on_enemy_entered_search_area(_unit: Unit) -> void:
    nearby_enemies.append(_unit)

## remove from list of nearby enemies
func _on_enemy_exited_search_area(_unit: Unit) -> void:
    # TODO need to figure out how references are handled in godot...
    nearby_enemies.erase(_unit)
