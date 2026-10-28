extends Node

# autoload singleton for managing signals during battle scenes

## represents various states the battle gameplay could be in
enum BattleState
{
    NOT_STARTED, # not yet started
    INIT, # initializing (paused), drawing cards, setup, etc
    RUNNING, # basic run state
    PAUSED, # basic pause state
    CARD_HELD, # holding a card (paused gameplay, but inputs/actions valid)
    END_VICTORY, # battle ended and player won
    END_DEFEAT # battle ended and player lost
}


## returns whether or not the state provided can be considered a "running" state
## from the point of view of gameplay.  i.e. should the battle keep running
func is_running_state(state: BattleState) -> bool:
    return state == BattleState.RUNNING or state == BattleState.CARD_HELD


## signal to spawn a unit at the mouse coordinates
## TODO notes
## - what about other effects? separate signal, or make this generic?
## - what happens if invalid position used?
#signal spawn_unit(position: Vector2, unit: PackedScene)

## signal to indicate when a card is seleceted to be held
## TODO could probably do this from the card class itself, but this is easier (for now)
signal card_held(card: Card)

## indicates an attempt to play a card
## TODO may need a better way to quickly attempt and return true/false on success/fail
signal play_card(card: Card, position: Vector2)

## indicates a card was successfully played
signal card_played(card: Card)

## indicates a card is being drawn from the deck
signal card_drawn(card_data: CardData)

## indicates a card was added to the discard pile
signal card_discarded(card: Card)

## indicates card placement failed
signal card_placement_fail(card: Card)

## indicates the state of gameplay needs to change
signal battle_state_update(new_state: BattleState)

## TODO temporary function, probably want a differnet signal/method for checking battle end conditions
signal defeat()

## TODO temporary function, probably want a differnet signal/method for checking battle end conditions
signal victory()
