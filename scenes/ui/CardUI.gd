class_name CardUI
extends Control

@export var card_scene: PackedScene

@onready var hand: DisplayableCardPile = $CardContainer/HandContainer
@onready var card_holder: Node2D = $CardHolder
@onready var deck: Deck = $CardContainer/DeckContainer/Deck
@onready var discard: Discard = $CardContainer/DiscardContainer/Discard

# data container for card ui. manages hand of cards, selected/held cards, etc


# card currently being held
var card_held: Card = null


# functionality needed:
# - receive signal that card was selected, so it can be displayed and held
# - receive signal that mouse clicked selected card while held, so it can be placed back
# - send signal that held card was placed on map, so unit/effect can be spawned
# - send signal to pause game when a card is selected (or pause or some other button pressed)


## set up signals and some initial cards to use (for debugging)
## TODO eventually load deck/cards/etc from player data
func _ready() -> void:
    # Connect to the global signals
    BattleSignalManager.card_held.connect(_on_card_held)
    BattleSignalManager.card_played.connect(_on_card_played)
    BattleSignalManager.card_drawn.connect(_on_card_drawn)
    BattleSignalManager.card_discarded.connect(_on_card_discarded)
    
    # ---
    # TODO this is debug to hard-code in some cards, for now
    # instantiate debug card scenes for hand
    var hand_card_pile: CardPile = CardPile.new([CardDataManager.cards[CardData.CardId.GOBLIN],
        CardDataManager.cards[CardData.CardId.ORC],
        CardDataManager.cards[CardData.CardId.SLIME_BLUE],
        CardDataManager.cards[CardData.CardId.WOLF],
        CardDataManager.cards[CardData.CardId.WARG] ],
        5)
    hand.add_cards(hand_card_pile)
    hand.max_size = hand_card_pile.max_size
    
    # TODO setting up some defaults for now. maybe discard shouldn't be unlimited size?
    var deck_card_pile: CardPile = CardPile.new([CardDataManager.cards[CardData.CardId.GOBLIN],
        CardDataManager.cards[CardData.CardId.GOBLIN],
        CardDataManager.cards[CardData.CardId.GOBLIN],
        CardDataManager.cards[CardData.CardId.ORC],
        CardDataManager.cards[CardData.CardId.SLIME_BLUE],
        CardDataManager.cards[CardData.CardId.SLIME_BLUE],
        CardDataManager.cards[CardData.CardId.SLIME_BLUE],
        CardDataManager.cards[CardData.CardId.SLIME_BLUE],
        CardDataManager.cards[CardData.CardId.WOLF],
        CardDataManager.cards[CardData.CardId.WARG] ],
        10)
    deck.cards = deck_card_pile
    deck.is_hand_full = hand.is_full()
    deck.cards.shuffle()
    
    # TODO implement discard stuff
    var discard_card_pile: CardPile = CardPile.new([], deck.cards.max_size)
    discard.cards = discard_card_pile
    
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
    for card in hand.cards:
        card.card_held = card_held
    
    # alert discard pile that held card changed
    discard.card_held = card_held


## when card is played, remove it from active hand and send to discard
func _on_card_played(card: Card):
    # TODO can this cause issues if card becomes null when notifying other listeners?
    # shouldn't be other listeners, but still may be a concern
    # TODO will card.card_data here create a copy, or a reference that immediately gets deleted?
    print("playing: ", card.card_data)
    discard.cards.append(card.card_data)
    
    # remove card from the hand and update the deck so it knows if hand is full or not
    hand.erase_card(card)
    deck.is_hand_full = hand.is_full()
    
    # report that no card is held now
    BattleSignalManager.card_held.emit(null)


## add card to the hand
func _on_card_drawn(card_data: CardData):
    hand.add_card(card_data)
    deck.is_hand_full = hand.is_full()


## when card is discarded, remove it from the hand and notify that it is no longer being held
## TODO this is the same as card_played right now.  will probably do different stuff later, like tick down draw timer
## or something.  Keeping as a separate function, for now
func _on_card_discarded(card: Card):
    print("discarding: ", card.card_data)
    discard.cards.append(card.card_data)
    
    # remove card from the hand and update the deck so it knows if hand is full or not
    hand.erase_card(card)
    deck.is_hand_full = hand.is_full()
    
    # report that no card is held now
    BattleSignalManager.card_held.emit(null)
