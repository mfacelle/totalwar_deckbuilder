class_name CardUI
extends Control

@export var card_scene: PackedScene

@onready var hand_container: HBoxContainer = $HandContainer
@onready var card_holder: Node2D = $CardHolder

# TODO really don't like how this is done... maybe build it via CardData?
@onready var card_held_scene: PackedScene = preload("res://scenes/ui/card_held.tscn")

# data container for card ui. manages hand of cards, selected/held cards, etc


# card currently being held
var card_held: Card = null

# data needed:
# - CardPile - list of cards currently on display in the hand
# - CardPile - deck of cards to draw from
# - CardPile - discard pile
var hand: CardPile
var deck: CardPile
var discard: CardPile

# functionality needed:
# - receive signal that card was selected, so it can be displayed and held
# - receive signal that mouse clicked selected card while held, so it can be placed back
# - send signal that held card was placed on map, so unit/effect can be spawned
# - send signal to pause game when a card is selected (or pause or some other button pressed)


func _ready() -> void:
    # Connect to the global EventBus signal
    BattleSignalManager.card_held.connect(_on_card_held)
    
    # TODO this is debug to hard-code in some cards, for now
    
    # instantiate debug card scenes for hand
    var card0 = card_scene.instantiate() as Card
    card0.card_type = CardData.CardType.GOBLIN
    var card1 = card_scene.instantiate() as Card
    card1.card_type = CardData.CardType.ORC
    var card2 = card_scene.instantiate() as Card
    card2.card_type = CardData.CardType.GOBLIN
    var card3 = card_scene.instantiate() as Card
    card3.card_type = CardData.CardType.WILD_ORC
    var card4 = card_scene.instantiate() as Card
    card4.card_type = CardData.CardType.ORC
    
    var hand_of_cards: CardPile = CardPile.new([card0, card1, card2, card3, card4])
    hand = hand_of_cards
    for card in hand.cards:
        hand_container.add_child(card)

func _on_card_held(new_card: Card) -> void:
    card_held = new_card
    
    # if card was removed from being held
    if card_held == null:
        # remove any cards currently held (should only be one, but this does the trick)
        for child in card_holder.get_children():
            child.queue_free()
    else:
        var new_card_held = card_held_scene.instantiate()
        new_card_held.card_type = card_held.card_type
        card_holder.add_child(new_card_held)
    
    # alert all cards in the hand that the held card changed
    for card in hand.cards:
        card.card_held = card_held
