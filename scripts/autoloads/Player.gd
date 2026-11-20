extends Node

# singleton for managing player data.
# TODO may be a better way than an autoload for handling this. singleton is fine for now.

signal deck_chosen(deck: DeckData)

# TODO future signals to add
# - card added
# - card removed (need to figure out how to properly index/id individual cards)
# - perks added/removed
# - money added/removed


var data: PlayerData


func _ready() -> void:
    deck_chosen.connect(on_deck_chosen)
    
    data = PlayerData.new()


## set the deck the player is using
func on_deck_chosen(deck: DeckData) -> void:
    data.current_deck_id = deck.id
    data.card_pile = deck.card_pile
    data.card_pile.max_size = deck.card_pile.max_size
