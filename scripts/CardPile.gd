class_name CardPile
extends Node

# represents a "pile" of cards, such a the deck, discard pile, or hand
# could also be used for shops

var cards: Array[Card] = []


func _init(_cards: Array[Card]):
    cards = _cards


# functionality needed:
# - get next card
# - add to end
# - shuffle
# - remove/pick cards, by index or reference (for random vs intentional)
