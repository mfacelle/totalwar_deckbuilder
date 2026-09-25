extends Node2D

# simple script to allow mouse clicks to create new golbin instances

## basic goblin object for debugging
@export var goblin: PackedScene


@onready var nav_map: TileMapLayer = $tilemap/navigation
@onready var units: Node = $entities/units

var spawn_index: int = 0

# all this from google ai:
func _unhandled_input(event: InputEvent) -> void:
    # 2. Check if the event is a left mouse button click and it was just pressed
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        spawn_object()

func spawn_object() -> void:
    if goblin:
        var new_object = goblin.instantiate()
        
        units.add_child(new_object)
        
        new_object.global_position = get_global_mouse_position()
        new_object.name = str("GoblinTmp", spawn_index)
        spawn_index += 1
