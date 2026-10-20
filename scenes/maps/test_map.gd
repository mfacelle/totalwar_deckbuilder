extends Node2D

# simple debug script to allow mouse clicks to create new unit instances.
# going super rough with this, not intended for final game at all

@export_category("Debug")
@export var debug_mode: bool = false

@export_category("Params")
## for debug/test stuff
@export var enemy_unit: PackedScene

@onready var world: Node2D = $world
@onready var nav_map: TileMapLayer = $world/tilemap/navigation
@onready var units: Node = $world/entities/units
@onready var enemies: Node = $world/entities/enemies
## TODO probably a better way to do this for checking mouse inputs
@onready var my_base: Base = $world/entities/units/MyBase

var friendly_spawn_index: int = 0
var enemy_spawn_index: int = 0
var mouse_in_spawn_area: bool = false
var battle_state: BattleSignalManager.BattleState = BattleSignalManager.BattleState.NOT_STARTED
# TODO might make sense to make a state machine for handling states,
# but we really only care about whether or not battle is paused right now, so some if checks work for now

# -----
# TODO basically here for debug, but most of this will likely become the real code in a battle/map class

var card_held: Card = null

func _ready() -> void:
    BattleSignalManager.card_held.connect(_on_card_held)
    BattleSignalManager.play_card.connect(_on_play_card)
    BattleSignalManager.battle_state_update.connect(_on_battle_state_update)
    BattleSignalManager.defeat.connect(_on_defeat)
    BattleSignalManager.victory.connect(_on_victory)
    
    # TODO this is apparently necessary... don't understand why the declaration above doesn't keep it null
    card_held = null
    
    # start in disabled state (NOT_STARTED)
    # TODO probably a better way to have initial state flow out to everything that needs it
    world.process_mode = Node.PROCESS_MODE_DISABLED
    
    # TODO this is a super clunky way to get the valid spawn area,
    # and doesn't handle when we can eventually add additional bases
    var spawn_area: Area2D = my_base.get_node("PlacementZone")
    spawn_area.mouse_entered.connect(_on_spawn_area_mouse_entered)
    spawn_area.mouse_exited.connect(_on_spawn_area_mouse_exited)


## when player picks up a card, store it here, to handle play actions
func _on_card_held(new_card: Card) -> void:
    # TODO this should really enter some kind of pause state, when a card is being held.
    # good enough for now and getting things tested/working
    # TODO this is kind of redundant with _on_play_card providing Card as arg
    if new_card == null:
        card_held = null
        # TODO base should only become null when battle lost, but that's not implemented yet
        # so this can potentially crash
        if my_base:
            my_base.set_spawn_area_visible(false)
    else:
        card_held = new_card
        if my_base:
            my_base.set_spawn_area_visible(true)


## handles playing a card when the player selects a spot on the map with a held card
func _on_play_card(card: Card, _position: Vector2) -> void:
    # do nothing for null
    if not card:
        return

    # TODO make into switch with separate functions for different card types
    if card.card_data.card_type == CardData.CardType.UNIT:
        # TODO this isn't quite enough... need to check against navigation region too
        if mouse_in_spawn_area:
            spawn_friendly_unit(card.unit_scene, _position)
            BattleSignalManager.card_played.emit(card)
        else:
            #  signal that placement failed
            BattleSignalManager.card_placement_fail.emit(card)


func _on_spawn_area_mouse_entered() -> void:
    mouse_in_spawn_area = true


func _on_spawn_area_mouse_exited() -> void:
    mouse_in_spawn_area = false
    

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

## TODO kind of temporary signal for handling battle end
func _on_defeat() -> void:
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.END_DEFEAT)

## TODO kind of temporary signal for handling battle end
func _on_victory() -> void:
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.END_VICTORY)

# -----


## handle left click to play a card, when one is held.
## also handle right clicks to spawn extra enemies, if debug is enabled
func _unhandled_input(event: InputEvent) -> void:
    # if left mouse button, spawn a friendly unit
    if event.is_action_pressed("LeftClick"):
        # TODO this signal seems unnecessary right now.  
        # Should eventually refactor into input handler and card player classes
        BattleSignalManager.play_card.emit(card_held, get_global_mouse_position())
    # else spawn an enemy one
    # TODO add some kind of debug flag to enable/disable this?
    elif event.is_action_pressed("RightClick") and debug_mode:
        print("[DEBUG_MODE] right click")
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



## updates paused state for entire world tree
## does not disable the top-level map node, so inputs can still be processed
func _on_battle_state_update(new_state: BattleSignalManager.BattleState) -> void:
    battle_state = new_state
    
    if battle_state == BattleSignalManager.BattleState.RUNNING or \
    battle_state == BattleSignalManager.BattleState.CARD_HELD:
        world.process_mode = Node.PROCESS_MODE_INHERIT
    else:
        world.process_mode = Node.PROCESS_MODE_DISABLED
