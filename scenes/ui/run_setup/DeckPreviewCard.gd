class_name DeckPreviewCard
extends Control

# basic card (similar to "card held" scene) that can be displayed

@export_category("Node References")
@export var card_background_node: TextureRect
@export var card_image_node: TextureRect

@onready var card_data: CardData = CardDataManager.cards[card_id]

## id of the card to be displayed
var card_id: CardData.CardId


func _ready() -> void:
    card_background_node.texture = load(card_data.card_bg_uid)
    card_image_node.texture = load(card_data.image_uid)
