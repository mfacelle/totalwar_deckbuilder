class_name DisplayableCardPile
extends Container


# represents a "pile" of displayable cards, such a the hand.
# cards here include PackedScene instances and can be displayed.
# could also be used for shops

# TODO almost the same as CardDataPile, but instantiates each card's scene

var cards: Array[Card] = []
var max_size: int = 0


## add cards to this pile, instantiating new scenes for each
#func add_cards(_cards: CardPile) -> void:
    #for card in _cards.cards:
        #add_card(card)
    

## adds a card to the pile, for the provided battle state
## TODO battle_state is unique to battles, but we might want DisplayableCardPile in non-battle scenes,
## such as shops or post-battle rewards, etc
func add_card(card: CardData, battle_state: BattleSignalManager.BattleState) -> bool:
    if is_full():
        return false

    var card_tmp = Card.BASE_CARD_SCENE.instantiate() as Card
    card_tmp.card_id = card.card_id
    card_tmp.battle_state = battle_state
    cards.append(card_tmp)
    add_child(card_tmp)
    return true


## removes a card, using a reference to an actual Card instance
func erase_card(_card: Card):
    cards.erase(_card)
    _card.queue_free()


func is_full() -> bool:
    if cards.size() < max_size:
        return false
    else:
        return true
