extends Control

@export var card_type: CardData.CardType

@onready var card_data: CardData = CardDataManager.cards[card_type]
@onready var unit_scene: PackedScene = load(card_data.unit_uid)
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var card_background: TextureRect = $CardBackground/TextureRect
@onready var name_label: Label = $CardDetails/Name
@onready var image: TextureRect = $CardDetails/Image
@onready var description_label: Label = $CardDetails/Description
# TODO really don't like how this is done... maybe build it via card_data?
@onready var card: PackedScene = preload("res://scenes/ui/card_held.tscn")

var card_highlighted: bool = false
var card_held: bool = false

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

func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if card_held:
            # if card is currently held, and this original spot is selected again, put it back
            # TODO want to hide/show entire card
            card_background.show()
            card_held = false
            # TODO need a much better way to remove card from card holder
            var card_holder_root = get_tree().get_root().get_node("Main/CanvasLayer/CardUI/CardHolder")
            for child in card_holder_root.get_children():
                child.queue_free()
            # TODO send signal for parent node
            #card_ui.card_held = false
        elif card_highlighted: # and not card_ui.card_held:
            # if this card is selected and we're not currently holding another card, allow holding this one
            var card_temp = card.instantiate()
            # TODO really don't like how this is done
            get_tree().get_root().get_node("Main/CanvasLayer/CardUI/CardHolder").add_child(card_temp)
            # temporarily hide card from UI, but keep it in place
            # TODO want to hide/show entire card
            card_background.hide()
            card_held = true
            # TODO send signal for parent node
            #card_ui.card_selected = true
