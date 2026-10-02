class_name CardDataPile
extends Node

# represents a "pile" of cards in data only, such a the deck or discard pile
# could also be used for shops.
# cards in this pile are not scenes and not displayable.

## set of cards contained in this pile
var cards: Array[CardData] = []
## maximum size of this pile (or -1 for unlimited)
var max_size: int


func _init(_cards: Array[CardData], _max_size: int):
    cards = _cards
    max_size = _max_size

# TODO implement accessor functions, i.e. add with limit checking

# functionality needed:
# - get next card
# - add to end
# - shuffle
# - remove/pick cards, by index or reference (for random vs intentional)
