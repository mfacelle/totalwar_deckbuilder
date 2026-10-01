extends Node2D

# simple debug script to allow mouse clicks to create new unit instances.
# going super rough with this, not intended for final game at all

## basic goblin object for debugging
@export var friendly_unit: PackedScene
@export var enemy_unit: PackedScene


@onready var nav_map: TileMapLayer = $world/tilemap/navigation
@onready var units: Node = $world/entities/units
@onready var enemies: Node = $world/entities/enemies

var friendly_spawn_index: int = 0
var enemy_spawn_index: int = 0

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
    if friendly_unit:
        # TODO just loading from orc card by default, for now
        #var new_unit = friendly_unit.instantiate() as Unit
        var unit_scene = load(CardDataManager.cards[CardData.CardType.ORC].unit_uid)
        var new_unit = unit_scene.instantiate() as Unit
        new_unit.global_position = get_global_mouse_position()
        new_unit.name = str("Friendly", friendly_spawn_index)
        new_unit.add_to_group("units", false)
        
        units.add_child(new_unit)
        
        friendly_spawn_index += 1


func spawn_enemy_unit() -> void:
    if enemy_unit:
        # TODO just loading from wild orc card by default, for now
        var unit_scene = load(CardDataManager.cards[CardData.CardType.WILD_ORC].unit_uid)
        var new_unit = unit_scene.instantiate() as Unit
        new_unit.entity_type = Unit.EntityType.ENEMY
        new_unit.enemy_group_name = "units"
        new_unit.global_position = get_global_mouse_position()
        new_unit.name = str("Enemy", enemy_spawn_index)
        new_unit.add_to_group("enemies", false)
        
        enemies.add_child(new_unit)
        
        enemy_spawn_index += 1
