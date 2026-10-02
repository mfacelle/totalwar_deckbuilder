class_name Card
extends Control

## base scene to use for cards (TODO may want to make this more dynamic later)
const BASE_CARD_SCENE: PackedScene = preload("uid://q08ll0ivd4uv")

@export var card_id: CardData.CardId

@onready var card_data: CardData = CardDataManager.cards[card_id]
@onready var unit_scene: PackedScene = load(card_data.unit_uid)
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var card_background: Container = $CardBackground
@onready var card_details: Container = $CardDetails
@onready var name_label: Label = $CardDetails/Name
@onready var image: TextureRect = $CardDetails/Image
@onready var description_label: Label = $CardDetails/Description

var card_highlighted: bool = false
var card_held: Card = null

func _ready() -> void:
    # set up fields on the card from CardData
    name_label.text = card_data.card_name
    description_label.text = card_data.description
    
    # set atlas texture, since we want a single sprite from a sprite sheet
    var atlas_texture = AtlasTexture.new()
    atlas_texture.atlas = load(card_data.image_uid)
    # TODO hard-coding for now, should make params in CardData
    atlas_texture.region =  Rect2(8, 8, 16, 16)    
    image.texture = atlas_texture


# TODO need to eventually use an area2D or something for mouse checks, so it moves with the animation
func _on_mouse_entered() -> void:
    anim_player.play("select")
    card_highlighted = true

func _on_mouse_exited() -> void:
    anim_player.play("deselect")
    card_highlighted = false


## when card is selected, allow for holding it to be played
func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if card_held == self:
            # if this card is currently held, and this original spot is selected again, put it back (by unhiding it)
            card_background.show()
            card_details.show()
            
            # set card held to null to avoid some kind of weird race condition with signal
            card_held = null
            BattleSignalManager.card_held.emit(null)
            
        elif card_highlighted and not card_held:
            # if this card is selected and we're not currently holding another card, allow holding this one
            # temporarily hide card from UI, but keep it in place in container
            # TODO consider making transparent (and show background only?), so it's clear where to place the card back
            card_background.hide()
            card_details.hide()
            
            # don't update held card until signal is processed, to avoid weird race condition or multiple rapid inputs
            BattleSignalManager.card_held.emit(self)
