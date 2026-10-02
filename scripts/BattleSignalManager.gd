extends Node

# autoload singleton for managing signals during battle scenes

## signal to spawn a unit at the mouse coordinates
## TODO notes
## - what about other effects? separate signal, or make this generic?
## - what happens if invalid position used?
signal spawn_unit(position: Vector2, unit: PackedScene)

## signal to indicate when a card is seleceted to be held
## TODO could probably do this from the card class itself, but this is easier (for now)
signal card_held(card: Card)
