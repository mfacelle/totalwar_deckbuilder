class_name PlayerData
extends Resource

# contains data for the player

## ID of the deck the player is currently using
var current_deck_id: DeckData.DeckId
## current set of cards in the player's deck
var card_pile: CardPile

# TODO eventually add:
# - perks
# - money
# - various stats/unlockables


func _init():
    current_deck_id = DeckData.DeckId.NONE
    card_pile = CardPile.new([])
