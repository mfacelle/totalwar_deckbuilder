class_name CardPile
extends Node

# represents a "pile" of cards in data only, such a the deck or discard pile
# could also be used for shops.
# cards in this pile are not scenes and not displayable.

## set of cards contained in this pile
var cards: Array[CardData] = []
## maximum size of this pile
var max_size: int


func _init(_cards: Array[CardData], _max_size: int):
    cards = _cards
    max_size = _max_size


## randomly shuffles all cards in this pile
func shuffle() -> void:
    cards.shuffle()

# TODO implement accessor functions, i.e. add with limit checking

func is_empty() -> bool:
    return cards.is_empty()


func draw() -> CardData:
    return cards.pop_back()


func size() -> int:
    return cards.size()


## appends to end of this pile, if there's room. Returns success/failure
func append(card_data: CardData) -> bool:
    if cards.size() < max_size:
        cards.append(card_data)
        return true
    else:
        return false
