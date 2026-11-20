class_name UnitCommandPanel
extends Control


@export_category("Node References")
@export var background_panel: Control
@export var command_hold_clickable: UnitCommandClickable
@export var command_attack_clickable: UnitCommandClickable
@export var command_retreat_clickable: UnitCommandClickable
@export var command_cancel_clickable: UnitCommandClickable

@export_category("Animation Params")
## how long the scale in/out should last
@export var scale_duration: float = 0.2
## normal displayed scale
@export var normal_scale: Vector2 = Vector2(1, 1)
## start/end scale for scaling in/out
@export var start_end_scale: Vector2 = Vector2(0.1, 0.1)

var scale_tween: Tween

## position that this command applies to (in world space, not canvas layer space)
var commanded_position: Vector2

## set up panel as invisible, since it will only appear when
## the player needs to input a command
func _ready() -> void:
    background_panel.scale = start_end_scale
    visible = false
    
    # TODO needs a different signal that provides a position to spawn this at
    BattleSignalManager.await_unit_command.connect(_on_awaiting_command)
    
    command_hold_clickable.handle_command.connect(_on_command_clicked)
    command_attack_clickable.handle_command.connect(_on_command_clicked)
    command_retreat_clickable.handle_command.connect(_on_command_clicked)
    command_cancel_clickable.handle_command.connect(_on_command_clicked)


## display panel and update battle state for listeners
func _on_awaiting_command(command_position: Vector2) -> void:
    commanded_position = command_position
    
    # convert world position to canvas layer position, so it draws in correct spot.
    # this isn't perfect, and you can see a bit of the command line indicator thing,
    # but it's fine for now
    var local_pos := ScreenPositionUtility.world_to_canvas_pos(command_position)

    show_panel(local_pos)
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.AWAITING_COMMAND)


## make panel visible, then run scale up tween
func show_panel(command_position: Vector2) -> void:
    ## TODO convert from position in subviewport world space to canvas layer space
    position = command_position
    background_panel.scale = start_end_scale
    visible = true
    animate_scale(normal_scale, Tween.TRANS_BACK, Tween.EASE_OUT)


## scale down and then hide panel when tween completes
func hide_panel() -> void:
    animate_scale(start_end_scale, Tween.TRANS_BACK, Tween.EASE_IN)
    scale_tween.tween_callback(on_scale_down_complete)

## set panel to not visible and location to origin
func on_scale_down_complete() -> void:
    visible = false
    position = Vector2(0, 0)


## scale animation for appear/disappear
func animate_scale(target_scale: Vector2, transition: Tween.TransitionType, ease_type: Tween.EaseType) -> void:
    if scale_tween and scale_tween.is_valid():
        scale_tween.kill()
    
    scale_tween = create_tween()
    scale_tween.set_ease(ease_type)
    scale_tween.set_trans(transition)
    scale_tween.tween_property(background_panel, "scale", target_scale, scale_duration)


## on button clicked, close window and emit command signal
func _on_command_clicked(command: UnitTypes.Command) -> void:
    hide_panel()
    BattleSignalManager.command_unit.emit(commanded_position, command)
    # TODO this might be the best place to set battle state, but should investigate
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.RUNNING)
