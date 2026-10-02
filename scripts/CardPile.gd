class_name CardPile
extends Node

# represents a "pile" of displayable cards, such a the hand.
# cards here include PackedScene instances and can be displayed
# could also be used for shops

# TODO almost the same as CardDataPile, but instantiates each card's scene

var cards: Array[Card] = []
var max_size: int


func _init(_cards: Array[Card], _max_size: int):
    cards = _cards
    max_size = _max_size


# functionality needed:
# - get next card
# - add to end
# - shuffle
# - remove/pick cards, by index or reference (for random vs intentional)
