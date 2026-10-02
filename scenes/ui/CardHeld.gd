class_name CardHeld
extends Control

# TODO this is basically just a smaller subset of Card class...
# consider refactoring to make this less clumsy and "change in two places" to manage?

## base scene to use for held cards (TODO may want to make this more dynamic later)
const BASE_CARD_HELD_SCENE: PackedScene = preload("uid://dd8kcd5vk6my6")

@export var card_id: CardData.CardId

@onready var card_data: CardData = CardDataManager.cards[card_id]
@onready var card_background: TextureRect = $CardBackground/TextureRect
@onready var image: TextureRect = $CardDetails/Image


func _ready() -> void:
    # set atlas texture, since we want a single sprite from a sprite sheet
    var atlas_texture = AtlasTexture.new()
    atlas_texture.atlas = load(card_data.image_uid)
    # TODO hard-coding for now, should make params in CardData
    atlas_texture.region =  Rect2(8, 8, 16, 16)    
    image.texture = atlas_texture

func _process(_delta: float) -> void:
    global_position = get_global_mouse_position()
