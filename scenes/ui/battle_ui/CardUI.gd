class_name CardUI
extends Control

@export_category("Params")
## base scene to use for cards displayed
@export var card_scene_uid: PackedScene
## base scene to use for held cards being played
@export var card_held_scene: PackedScene


@export_category("Initialization")
# TODO some of this will likely be replaced by tweens to animate card drawing
## how quickly to draw individual card hand, in seconds
@export var draw_card_delay: float = 0.15
## delay after drawing all cards before officially starting battle
@export var start_delay: float = 0.5

@export_category("Node References")
@export var hand: DisplayableCardPile
@export var card_holder: Control
@export var deck: Deck
@export var discard: Discard

@export_category("(TEMP) Card Info")
@export var default_hand_size: int = 4

# data container for card ui. manages hand of cards, selected/held cards, etc


# card currently being held
var card_held: Card = null
var battle_state: BattleSignalManager.BattleState = BattleSignalManager.BattleState.NOT_STARTED


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
    BattleSignalManager.battle_state_update.connect(_on_battle_state_update)
    
    # ---
    # TODO this is debug to hard-code in some cards, for now
    # instantiate debug card scenes for hand
    #var hand_card_pile: CardPile = CardPile.new([CardDataManager.cards[CardData.CardId.GOBLIN],
        #CardDataManager.cards[CardData.CardId.ORC],
        #CardDataManager.cards[CardData.CardId.SLIME_BLUE],
        #CardDataManager.cards[CardData.CardId.WOLF],
        #CardDataManager.cards[CardData.CardId.WARG] ],
        #5)
    var hand_card_pile: CardPile = CardPile.new([], default_hand_size)
    #hand.add_cards(hand_card_pile)
    hand.max_size = hand_card_pile.max_size
    
    # TODO kind of a hack to ensure cards start in the right state, since add_cards will assume RUNNING
    #for card in hand.cards:
        #card.battle_state = battle_state
    
    # TODO setting up some defaults for now. eventually pull from some kind of player information
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
    deck.set_card_pile(deck_card_pile)
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
        
        # return to running state now that card is no longer held
        BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.RUNNING)
    else:
        # instantiate CardHeld scene and add to card holder node
        var new_card_held: CardHeld = card_held_scene.instantiate() as CardHeld
        new_card_held.card_id = card_held.card_id
        card_holder.add_child(new_card_held)
        
        # alert listeners that battle state should now be paused
        BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.CARD_HELD)
    
    # alert all cards in the hand that the held card changed
    for card in hand.cards:
        card.card_held = card_held
    
    # alert discard pile that held card changed
    discard.card_held = card_held


## when card is played, remove it from active hand and send to discard
func _on_card_played(card: Card) -> void:
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
    
    # return to running state
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.RUNNING)


## add card to the hand
func _on_card_drawn(card_data: CardData):
    # TODO is it possible for the hand to be full when this function is hit?
    # might be eventually, consider checking return value here and doing something else
    hand.add_card(card_data, battle_state)
    deck.is_hand_full = hand.is_full()


## when card is discarded, remove it from the hand and notify that it is no longer being held
## TODO this is the same as card_played right now.  will probably do different stuff later, like tick down draw timer
## or something.  Keeping as a separate function, for now
func _on_card_discarded(card: Card) -> void:
    print("discarding: ", card.card_data)
    discard.cards.append(card.card_data)
    
    # remove card from the hand and update the deck so it knows if hand is full or not
    hand.erase_card(card)
    deck.is_hand_full = hand.is_full()
    
    # report that no card is held now
    BattleSignalManager.card_held.emit(null)
    
    # return to running state
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.RUNNING)


## updates battle state for all UI elements
func _on_battle_state_update(new_state: BattleSignalManager.BattleState) -> void:
    battle_state = new_state
    
    # update all UI elements, including cards in the hand, so they process inputs appropriately
    for card in hand.cards:
        card.battle_state = new_state
    deck.battle_state = new_state
    discard.battle_state = new_state
    
    # TODO probably need to do something to return held card to hand. ignoring for now
    
    # if initializing, draw cards from deck into the hand
    if new_state == BattleSignalManager.BattleState.INIT:
        initial_draw_cards()
    

## draws cards from the deck into the hand, to fill the size of the hand
func initial_draw_cards() -> void:
    # draw cards, either until hand is full or deck is empty
    while not hand.is_full() and not deck.is_empty():
        # small delay, so cards are drawn in real-time
        await get_tree().create_timer(draw_card_delay).timeout
        
        var drawn_card: CardData = deck.draw_card()
        # redundant check, in case deck didn't have enough cards
        if drawn_card:
            BattleSignalManager.card_drawn.emit(drawn_card)
    
    # set battle state to running
    # TODO or are there other things that need to be set up in other classes first?
    # i.e. let player play some initial cards or do some map stuff?
    await get_tree().create_timer(start_delay).timeout
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.RUNNING)
