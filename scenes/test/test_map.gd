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
## TODO basically here for debug, but most of this will likely become the real code in a battle/map class
var card_held: Card = null

func _ready() -> void:
    BattleSignalManager.card_held.connect(_on_card_held)
    BattleSignalManager.play_card.connect(_on_play_card)
    
    # TODO this is apparently necessary... don't understand why the declaration above doesn't keep it null
    card_held = null

## when player picks up a card, store it here, to handle play actions
func _on_card_held(new_card: Card) -> void:
    # TODO this should really enter some kind of pause state, when a card is being held.
    # good enough for now and getting things tested/working
    # TODO this is kind of redundant with _on_play_card providing Card as arg
    if new_card == null:
        card_held = null
    else:
        card_held = new_card

## handles playing a card when the player selects a spot on the map with a held card
func _on_play_card(card: Card, _position: Vector2) -> void:
    # do nothing for null
    if not card:
        return

    # TODO make into switch with separate functions for different card types
    if card.card_data.card_type == CardData.CardType.UNIT:
        # TODO eventually need to check that position is valid, and only emit success if it was
        spawn_friendly_unit(card.unit_scene, _position)
        BattleSignalManager.card_played.emit(card)


## spawns a friendly unit, based on the card provided
func spawn_friendly_unit(unit: PackedScene, _position: Vector2) -> void:
    print("spawn_friendly_unit, unit=", unit)
    if unit:
        # TODO just loading from orc card by default, for now
        var new_unit = unit.instantiate() as Unit
        new_unit.global_position = _position
        new_unit.name = str("Friendly", friendly_spawn_index)
        new_unit.add_to_group("units", false)
        
        units.add_child(new_unit)
        
        friendly_spawn_index += 1

# -----


## TODO make this use actual inputs via godot, not just checking for mouse click manually
func _unhandled_input(event: InputEvent) -> void:
    # if left mouse button, spawn a friendly unit
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        print("left click")
        # TODO this signal seems unnecessary right now.  
        # Should eventually refactor into input handler and card player classes
        BattleSignalManager.play_card.emit(card_held, get_global_mouse_position())
    # else spawn an enemy one
    # TODO add some kind of debug flag to enable/disable this?
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
        print("right click")
        spawn_enemy_unit()



## DEBUG FUNCTION
## spawns an enemy unit
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
