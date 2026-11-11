extends Node2D

# simple debug script to allow mouse clicks to create new unit instances.
# going super rough with this, not intended for final game at all

@export_category("Debug")
@export var debug_mode: bool = false

@export_category("Params")
## for debug/test stuff
@export var enemy_unit: PackedScene

@export_category("Node References")
@export var world: Node2D
@export var nav_map: TileMapLayer
@export var units: Node
@export var enemies: Node
## TODO probably a better way to do this for checking mouse inputs
@export var my_base: Base

var friendly_spawn_index: int = 0
var enemy_spawn_index: int = 0
var mouse_in_spawn_area: bool = false
var battle_state: BattleSignalManager.BattleState = BattleSignalManager.BattleState.NOT_STARTED
# TODO might make sense to make a state machine for handling states,
# but we really only care about whether or not battle is paused right now, so some if checks work for now


var card_held: Card = null

func _ready() -> void:
    BattleSignalManager.card_held.connect(_on_card_held)
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


## handles attempting to play a card when the player selects a spot on the map with a held card
func attempt_play_card(card: Card, _position: Vector2) -> void:
    # do nothing for null
    if not card:
        return

    # TODO make into switch with separate functions for different card types
    if card.card_data.card_type == CardData.CardType.UNIT:
        # TODO this isn't quite enough... need to check against navigation region eventually
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
        new_unit.battle_state = battle_state
        new_unit.add_to_group("units", false)
        
        units.add_child(new_unit)
        
        friendly_spawn_index += 1

## TODO kind of temporary signal for handling battle end
func _on_defeat() -> void:
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.END_DEFEAT)

## TODO kind of temporary signal for handling battle end
func _on_victory() -> void:
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.END_VICTORY)


## attempt to command a unit to the provided position
func attempt_command_unit(new_position: Vector2) -> void:
    # TODO need to check against navigation for valid placement
    BattleSignalManager.command_unit.emit(new_position)
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.RUNNING)


## handle left click to play a card, when one is held.
## also handle right clicks to spawn extra enemies, if debug is enabled
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("LeftClick"):
        # basic state machine for handling different input states
        
        # if card_held state and a card is actually held, try to play it
        if battle_state == BattleSignalManager.BattleState.CARD_HELD and card_held:
            # TODO consider calling this as deferred?
            attempt_play_card(card_held, get_global_mouse_position())
            # mark input as handled so it does nothing else
            get_viewport().set_input_as_handled()
        # if commanding a unit, try to command it
        elif battle_state == BattleSignalManager.BattleState.COMMANDING_UNIT:
            # TODO signal here is redundant, since it needs to go through _on_unit_commanded anyway
            attempt_command_unit(get_global_mouse_position())
    
    # DEBUG ONLY: spawn an enemy unit with right click
    if event.is_action_pressed("RightClick") and debug_mode:
        print("[DEBUG_MODE] right click")
        spawn_enemy_unit()


## DEBUG FUNCTION
## spawns an enemy unit
func spawn_enemy_unit() -> void:
    if enemy_unit:
        # TODO just loading from wild orc card by default, for now
        var new_unit = enemy_unit.instantiate() as Unit
        new_unit.entity_type = UnitTypes.EntityType.ENEMY
        new_unit.enemy_group_name = "units"
        new_unit.global_position = get_global_mouse_position()
        new_unit.name = str("Enemy", enemy_spawn_index) 
        new_unit.battle_state = battle_state
        new_unit.add_to_group("enemies", false)
        
        enemies.add_child(new_unit)
        
        enemy_spawn_index += 1


## updates paused state for entire world tree
## does not disable the top-level map node, so inputs can still be processed
func _on_battle_state_update(new_state: BattleSignalManager.BattleState) -> void:
    battle_state = new_state
    
    if BattleSignalManager.is_running_state(battle_state):
        world.process_mode = Node.PROCESS_MODE_INHERIT
    else:
        world.process_mode = Node.PROCESS_MODE_DISABLED
