class_name Unit
extends CharacterBody2D
# base unit object, handles simple commands, states, movement.
# create derived classes to implement specific logic for units

# TODO really need to start looking into state machine for this. getting too big/complex
# Notes on this:
# - how to handle unit commanded position vs unit retreat, 
#   when we want unit to run away and ignore enemies vs move to a position and attack them.
#   consider some kind of popup when selecting a position to move to (i.e. attack vs run)
# - probably need a way to set behaviors via map info, rather than in-editor 
#   (especially if enemies can spawn mid-battle). can revisit this way later
# - need some kind of logic to handle condition when player is out of units.
#   do we want all enemies to rampage? what about if they still have cards?
#   this logic probably belongs in map class or create an overall battle manager

# -----------------------------------------------------------------------------
# signals

# emitted for other units to listen to
signal unit_died(unit: Unit)


# -----------------------------------------------------------------------------
# export vars

@export_category("Parameters")
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

@export_category("Behavior")
## default unit command
@export var default_command: UnitTypes.Command = UnitTypes.Command.DEFAULT
## unit behavior
@export var behavior: UnitTypes.BehaviorType = UnitTypes.BehaviorType.DEFAULT
## default attack type
@export var search_behavior: UnitTypes.SearchBehavior = UnitTypes.SearchBehavior.CLOSEST

@export_category("Node References")
@export var anim_tree: AnimationTree
@export var nav_agent: NavigationAgent2D
@export var hurt_box: Area2D
@export var hit_box: Area2D
@export var sprite: Sprite2D
@export var click_area: Area2D

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


# -----------------------------------------------------------------------------
# onready vars

## data for this unit, for setting stats
@onready var unit_data: UnitData = UnitDataManager.units[unit_id]
@onready var anim_playback: AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]


# -----------------------------------------------------------------------------
# member vars

# components from constants, since they apply to all units
var enemy_search_area_scene: PackedScene = UnitConstants.ENEMY_SEARCH_AREA_SCENE
var command_line_scene: PackedScene = UnitConstants.COMMAND_LINE_SCENE

# components - start off as null, since some have constructor args or don't always exist

var health_component: HealthComponent = null
var click_component: ClickableComponent = null
var nearby_enemy_search_area: NearbyEnemySearchAreaComponent = null
var command_line_component: CommandLineComponent = null
var enemy_search_component: BasicEnemySearchComponent = null
# TODO more components to add:
# - spell effects (buffs/debuffs)
# TODO later on, possible other components:
# - behavior component (handles attack/move logic and switching states/commands)
# - attack component (handles attacking logic and timers)
# - move component (handles move logic and stuck checks/timers)

## position the unit has been commanded to move to
var commanded_position: Vector2

# params and attributes

var state: UnitTypes.State = UnitTypes.State.IDLE
var command: UnitTypes.Command = default_command
var battle_state: BattleSignalManager.BattleState = BattleSignalManager.BattleState.NOT_STARTED
var target_enemy: Unit = null
var attack_ready: bool = true
var stuck_timer: float = 0
var tween: Tween
#var last_position: Vector2


# -----------------------------------------------------------------------------
# initialization

func _ready() -> void:
    # only enable animations when game is active (so editor doesn't keep them running)
    anim_tree.set_active(true)
    
    # need to redundantly set these up. don't seem to be getting set properly
    state = UnitTypes.State.IDLE
    command = default_command
    battle_state = BattleSignalManager.BattleState.NOT_STARTED
    
    # set commanded position to initial location
    commanded_position = global_position
    
    set_up_collision_and_enemy_search()
    
    # set up health component and add as child node (for better debugging)
    health_component = HealthComponent.new(unit_data.max_health)
    health_component.health_changed.connect(on_health_changed)
    health_component.died.connect(on_die)
    add_child(health_component)
    
    # set up initial state and position
    #last_position = global_position
    
    BattleSignalManager.battle_state_update.connect(_on_battle_state_update)
    
    # wait a frame for navigation to be set up
    await get_tree().physics_frame


## sets layers and masks for collision, as well as setting up clickable
## and enemy search areas
func set_up_collision_and_enemy_search() -> void:
    # set up area 2d components and nodes to properly handle collision layers
    
    var enemy_type: UnitTypes.EntityType = UnitTypes.EntityType.ENEMY
    
    # set layer used for damage collisions affecting this object.
    # also ensure only friendly units can be selected
    if entity_type == UnitTypes.EntityType.FRIENDLY:
        hurt_box.set_collision_layer_value(UnitTypes.EntityType.FRIENDLY, true)
        hit_box.set_collision_mask_value(UnitTypes.EntityType.ENEMY, true)
        enemy_type = UnitTypes.EntityType.ENEMY
        
        # set up click component for friendly units
        click_component = ClickableComponent.new(click_area)
        click_component.clicked_on.connect(_on_click)
        click_component.hover_start.connect(_on_hover_start)
        click_component.hover_end.connect(_on_hover_end)
        click_component.name = name + "_clickComponent"
    else:
        hurt_box.set_collision_layer_value(UnitTypes.EntityType.ENEMY, true)
        hit_box.set_collision_mask_value(UnitTypes.EntityType.FRIENDLY, true)
        enemy_type = UnitTypes.EntityType.FRIENDLY
        
        # use noop for mouse detection and clicks for enemies,
        # and make their click area not pickable
        click_component = NoopClickableComponent.new(click_area)
        click_area.input_pickable = false
    
    hit_box.area_entered.connect(_on_hit_box_area_entered)
    
    # set up search area for nearby enemies
    nearby_enemy_search_area = enemy_search_area_scene.instantiate() as NearbyEnemySearchAreaComponent
    nearby_enemy_search_area.enemy_type = enemy_type
    nearby_enemy_search_area.search_radius = unit_data.enemy_search_range
    add_child(nearby_enemy_search_area)
    
    # set up enemy search component
    if command == UnitTypes.Command.RAMPAGE:
        enemy_search_component = RampagingEnemySearchComponent.new( \
            nearby_enemy_search_area, unit_data.target_search_delay, enemy_group_name, search_behavior)
    else:
        enemy_search_component = BasicEnemySearchComponent.new( \
            nearby_enemy_search_area, unit_data.target_search_delay, enemy_group_name, search_behavior)
    
    enemy_search_component.new_target_enemy.connect(_on_new_target_enemy)
    add_child(enemy_search_component)


# -----------------------------------------------------------------------------
# overall updates

## update battle state
func _on_battle_state_update(new_state: BattleSignalManager.BattleState) -> void:
    battle_state = new_state


## handle updates to command state
func _on_command_update(new_command: UnitTypes.Command) -> void:
    # if moving out of rampage, set up basic enemy search component
    # TODO lots of redundant code in both blocks, along with init code...
    if command == UnitTypes.Command.RAMPAGE and new_command != UnitTypes.Command.RAMPAGE:
        var temp_enemy_list = enemy_search_component.nearby_enemies
        enemy_search_component.queue_free()
        enemy_search_component = BasicEnemySearchComponent.new( \
            nearby_enemy_search_area, unit_data.target_search_delay, enemy_group_name, search_behavior)
        enemy_search_component.nearby_enemies = temp_enemy_list
        enemy_search_component.new_target_enemy.connect(_on_new_target_enemy)
        add_child(enemy_search_component)
    # if moving to rampage, set up rampaging enemy search component
    elif command != UnitTypes.Command.RAMPAGE and new_command == UnitTypes.Command.RAMPAGE:
        var temp_enemy_list = enemy_search_component.nearby_enemies
        enemy_search_component.queue_free()
        enemy_search_component = RampagingEnemySearchComponent.new( \
            nearby_enemy_search_area, unit_data.target_search_delay, enemy_group_name, search_behavior)
        enemy_search_component.nearby_enemies = temp_enemy_list
        enemy_search_component.new_target_enemy.connect(_on_new_target_enemy)
        add_child(enemy_search_component)
    
    command = new_command


## processes various unit states
## TODO would be better to refactor into proper state machine soon
func _physics_process(delta: float) -> void:
    # TODO will also need to handle commands along with UnitTypes.State.
    # refactor this into a more proper state machine.
    # TODO state machine notes (probably based on Command, not State...? weird)
    # - DEFAULT: move to commanded position or active target, search for new targets
    # - RETREAT: move to commanded position only. once reached, switch to DEFAULT
    # - RAMPAGE: search to and search for active targets only (no range limit)
    
    # if command line node is present, update start/end positions.
    # component will be updated/drawn in its own _process function
    if command_line_component:
        command_line_component.start_position = global_position
        command_line_component.end_position = get_global_mouse_position()
    
    # do nothing else here if dead or attacking
    if state == UnitTypes.State.DEAD or state == UnitTypes.State.ATTACK:
        return
    
    if target_enemy:
        # if enemy exists and is within range, attempt to attack it
        if global_position.distance_to(target_enemy.global_position) < unit_data.attack_range:
            if attack_ready:
                attack()
        else: # move towards it
            move(delta)
    elif global_position.distance_to(commanded_position) > unit_data.attack_range:
        move(delta)
    else: # not moving, do nothing
        state = UnitTypes.State.IDLE
        velocity = Vector2.ZERO
    
    # ensure correct animation state is set
    update_animation()


## update animation tree based on state
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


# -----------------------------------------------------------------------------
# enemy search

func _on_new_target_enemy(enemy: Unit) -> void:
    target_enemy = enemy


# -----------------------------------------------------------------------------
# movement

## handle movement based on target/state
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
    
    # if we have a target enemy, move towards it.
    if target_enemy:
        nav_agent.target_position = target_enemy.global_position
    # otherwise, move to commanded position
    else:
        nav_agent.target_position = commanded_position
    
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


## update velocity callback
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
    if state != UnitTypes.State.STUCK:
        velocity = safe_velocity
    # not calling move_and_slide from this function, because this callback is hit from various places


# -----------------------------------------------------------------------------
# attack

func attack() -> void:
    # do nothing if already attacking
    if state == UnitTypes.State.ATTACK:
        return
    
    # TODO this is a clunky way to do this. need a state machine or an apply_behaviors function?
    if behavior == UnitTypes.BehaviorType.RAMPAGE_AFTER_ATTACK:
        # TODO doing this like a signal, because it should probably be one coming 
        # from a component eventually
        _on_command_update(UnitTypes.Command.RAMPAGE)
    elif behavior == UnitTypes.BehaviorType.ATTACK_AND_STAY:
        # upate commanded position to this spot, so unit stays there after attacking is done
        commanded_position = global_position
    
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


# -----------------------------------------------------------------------------
# damage/health/die

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
    
    # clear command line, if present (or it'll stick around during death animation).
    # need to also set battle state back to running, or we could end up in a weird state
    if command_line_component:
        BattleSignalManager.command_unit.disconnect(_on_unit_commanded)
        command_line_component.queue_free()
        BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.RUNNING)
    
    # make unit not monitorable, and stop searching for enemies
    hurt_box.set_deferred("monitorable", false)
    nearby_enemy_search_area.set_deferred("monitoring", false)
    
    unit_died.emit(self as Unit)
    
    update_animation()


## delete this unit when die completed
func _on_die_animation_finished():
    queue_free()


# -----------------------------------------------------------------------------
# click/hover/command

## handle logic for when this unit is clicked on
func _on_click() -> void:
    if BattleSignalManager.is_unit_interactable_state(battle_state):
        print(name, " clicked on")
        command_line_component = command_line_scene.instantiate() as CommandLineComponent
        command_line_component.start_position = global_position
        command_line_component.end_position = get_global_mouse_position()
        command_line_component.search_zone_radius = unit_data.enemy_search_range
        add_child(command_line_component)
        BattleSignalManager.command_unit.connect(_on_unit_commanded)
        # emit battle state signal deferred, to allow multiple units to be clicked on simultaneously
        BattleSignalManager.battle_state_update.emit.call_deferred(BattleSignalManager.BattleState.COMMANDING_UNIT)
        # set commanded position to current position so unit stops moving, but
        # can still attack enemies, if any are currently in range
        commanded_position = global_position


## update unit commanded position.
## assumes position is valid and possible to get to
## TODO need to enforce via map class on click
func _on_unit_commanded(new_position: Vector2) -> void:
    print(name, " commanded to ", new_position)
    commanded_position = new_position
    # stop listening for commnd notifications
    BattleSignalManager.command_unit.disconnect(_on_unit_commanded)
    command_line_component.queue_free()


## highlight sprite on mouse hover
func _on_hover_start() -> void:
    if BattleSignalManager.is_unit_interactable_state(battle_state):
        # TODO ad tween to fade in/out?
        sprite.material = highlight_shader


## return to normal when mouse no longer hovers
func _on_hover_end() -> void:
    # do this regardless of battle state, it's okay to end hover shader
    # TODO ad tween to fade in/out?
    sprite.material = null
