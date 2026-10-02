class_name DisplayableCardPile
extends Container


# represents a "pile" of displayable cards, such a the hand.
# cards here include PackedScene instances and can be displayed
# could also be used for shops

# TODO almost the same as CardDataPile, but instantiates each card's scene

var cards: Array[Card] = []
var max_size: int = 0


## add cards to this pile, instantiating new scenes for each
func add_cards(_cards: CardPile):
    for card in _cards.cards:
        add_card(card)
    

## add a card to this pile, by instantiating a new scene
func add_card(_card: CardData):
    # TODO if successfully added (i.e. max size not hit)
    var card_tmp = Card.BASE_CARD_SCENE.instantiate() as Card
    card_tmp.card_id = _card.card_id
    cards.append(card_tmp)
    add_child(card_tmp)


## removes a card, using a reference to an actual Card instance
func erase_card(_card: Card):
    cards.erase(_card)
    _card.queue_free()

# functionality needed:
# - get next card
# - add to end
# - shuffle
# - remove/pick cards, by index or reference (for random vs intentional)
