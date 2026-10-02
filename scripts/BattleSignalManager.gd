extends Node

# autoload singleton for managing signals during battle scenes

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
