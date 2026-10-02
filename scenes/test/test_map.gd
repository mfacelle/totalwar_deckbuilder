extends Node2D

# simple debug script to allow mouse clicks to create new unit instances.
# going super rough with this, not intended for final game at all

## for debug/test stuff
@export var enemy_unit: PackedScene

@onready var nav_map: TileMapLayer = $world/tilemap/navigation
@onready var units: Node = $world/entities/units
@onready var enemies: Node = $world/entities/enemies

var friendly_spawn_index: int = 0
var enemy_spawn_index: int = 0

# -----
## TODO basically here for debug, but some form of this will become the real code
var friendly_unit: PackedScene = null

func _ready() -> void:
    BattleSignalManager.card_held.connect(_on_card_held)
    
    # TODO this is apparently necessary... don't understand why the declaration above doesn't keep it null
    friendly_unit = null

func _on_card_held(new_card: Card) -> void:
    # TODO this should really enter some kind of pause state, when a card is being held.
    # good enough for now and getting things tested/working
    print("on_card_held")
    if new_card == null:
        friendly_unit = null
    else:
        friendly_unit = new_card.unit_scene

# -----

func _unhandled_input(event: InputEvent) -> void:
    # if left mouse button, spawn a friendly unit
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        print("left click")
        spawn_friendly_unit()
    # else spawn an enemy one
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
        print("right click")
        spawn_enemy_unit()


func spawn_friendly_unit() -> void:
    print("spawn_friendly_unit, unit=", friendly_unit)
    if friendly_unit:
        # TODO just loading from orc card by default, for now
        var new_unit = friendly_unit.instantiate() as Unit
        new_unit.global_position = get_global_mouse_position()
        new_unit.name = str("Friendly", friendly_spawn_index)
        new_unit.add_to_group("units", false)
        
        units.add_child(new_unit)
        
        friendly_spawn_index += 1


func spawn_enemy_unit() -> void:
    if enemy_unit:
        # TODO just loading from wild orc card by default, for now
        var new_unit = enemy_unit.instantiate() as Unit
        new_unit.entity_type = Unit.EntityType.ENEMY
        new_unit.enemy_group_name = "units"
        new_unit.global_position = get_global_mouse_position()
        new_unit.name = str("Enemy", enemy_spawn_index)
        new_unit.add_to_group("enemies", false)
        
        enemies.add_child(new_unit)
        
        enemy_spawn_index += 1
