class_name CardUI
extends Control

@export var card_scene: PackedScene

@onready var hand_container: DisplayableCardPile = $HandContainer
@onready var card_holder: Node2D = $CardHolder

# data container for card ui. manages hand of cards, selected/held cards, etc


# card currently being held
var card_held: Card = null

# data needed:
# - CardPile - deck of cards to draw from
# - CardPile - discard pile
var deck: CardPile
var discard: CardPile

# functionality needed:
# - receive signal that card was selected, so it can be displayed and held
# - receive signal that mouse clicked selected card while held, so it can be placed back
# - send signal that held card was placed on map, so unit/effect can be spawned
# - send signal to pause game when a card is selected (or pause or some other button pressed)


func _ready() -> void:
    # Connect to the global signals
    BattleSignalManager.card_held.connect(_on_card_held)
    BattleSignalManager.card_played.connect(_on_card_played)
    
    # ---
    # TODO this is debug to hard-code in some cards, for now
    # instantiate debug card scenes for hand
    var card_pile: CardPile = CardPile.new([CardDataManager.cards[CardData.CardId.GOBLIN],
        CardDataManager.cards[CardData.CardId.ORC],
        CardDataManager.cards[CardData.CardId.WILD_ORC],
        CardDataManager.cards[CardData.CardId.WOLF],
        CardDataManager.cards[CardData.CardId.WARG] ],
        5)
    hand_container.add_cards(card_pile)
    hand_container.max_size = 10
    
    # TODO setting up some defaults for now. maybe discard shouldn't be unlimited size?
    deck = CardPile.new([], 10)
    discard = CardPile.new([], 10)
    
    # ---


## when held card changes, notify objects and set cards displayed
func _on_card_held(new_card: Card) -> void:
    card_held = new_card
    
    # if card was removed from being held
    if card_held == null:
        # remove any cards currently held (should only be one, but this does the trick)
        for child in card_holder.get_children():
            child.queue_free()
    else:
        var new_card_held = CardHeld.BASE_CARD_HELD_SCENE.instantiate()
        new_card_held.card_id = card_held.card_id
        card_holder.add_child(new_card_held)
    
    # alert all cards in the hand that the held card changed
    for card in hand_container.cards:
        card.card_held = card_held


## when card is played, remove it from active hand and send to discard
func _on_card_played(card: Card):
    # TODO can this cause issues if card becomes null when notifying other listeners?
    # shouldn't be other listeners, but still may be a concern
    # TODO will card.card_data here create a copy, or a reference that immediately gets deleted?
    print("discarding: ", card.card_data)
    discard.cards.append(card.card_data)
    for discarded in discard.cards:
        print(discarded)
    hand_container.erase_card(card)
    BattleSignalManager.card_held.emit(null)
