class_name CommandLineComponent
extends Node2D

@export var line: Line2D
@export var endpoint_sprite: Sprite2D

var start_position: Vector2
var end_position: Vector2
var search_zone_radius: int
var search_circle_color: Color

var battle_state := BattleSignalManager.BattleState.NOT_STARTED


func _ready() -> void:
    # set circle color to overall node modulate color, then make transparent
    search_circle_color = modulate
    search_circle_color.a = 0.25
    
    BattleSignalManager.battle_state_update.connect(_on_battle_state_update)


## draw the line, ensuring it has only two points.
## assumes start/end position are properly updated
func _physics_process(_delta: float) -> void:
    # only draw the line if we're in a state that allows it
    # TODO this might not be the best check for this...
    if BattleSignalManager.is_unit_interactable_state(battle_state):
        draw_command_line()


func draw_command_line() -> void:
    # clear points and reset
    line.clear_points()
    line.add_point(Vector2.ZERO)
    line.add_point(Vector2.ZERO)
    
    # round positions, then convert start/end positions to line space,
    # weird pixel-snapping issues and jitter.
    # note: converting then rounding still makes it super jittery
    
    line.set_point_position(0, line.to_local(start_position.round()))
    
    var line_end_pos: Vector2 = line.to_local(end_position.round())
    line.set_point_position(1, line_end_pos)
    endpoint_sprite.position = line_end_pos
    
    # draw search area circle
    queue_redraw()


## draw search zone at endpoint so it's clear where unit can search for enemies
func _draw() -> void:
    var line_end_pos: Vector2 = line.to_local(end_position.round())
    draw_circle(line_end_pos, search_zone_radius, search_circle_color)


## update battle state
func _on_battle_state_update(new_state: BattleSignalManager.BattleState) -> void:
    battle_state = new_state
