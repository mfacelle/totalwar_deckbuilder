class_name DeckSelection
extends Control

# TODO probably want deck id, and then load textures etc from that,
# instead of having params for each texture, info, etc

## signal to notify UI that this deck is being hovered over / selected
signal deck_hovered(deck_id: DeckData.DeckId)
signal deck_hover_end()
signal deck_clicked(deck_id: DeckData.DeckId)

@export_category("Node References")
@export var card_node: TextureRect

@export_category("Animation Params")
## how far to offset the card when hovering over it
@export var hover_offset: Vector2 = Vector2(0.0, -64.0)
## normal offset
@export var normal_offset: Vector2 = Vector2(0.0, 0.0)
## duration of transition for hover offset, in seconds
@export var hover_offset_duration: float = 0.25
## amount to scale top card by when clicking on it
@export var click_scale: Vector2 = Vector2(0.9, 0.9)
## normal scale
@export var normal_scale: Vector2 = Vector2(1.0, 1.0)
## duration of transition for click scale effect
@export var click_duration: float = 0.2


@onready var deck_data: DeckData = DeckDataManager.decks[deck_id]

var deck_id: DeckData.DeckId
var tween: Tween


func _ready() -> void:
    card_node.texture = load(deck_data.cardback_texture_uid)


func _on_mouse_entered() -> void:
    animate_offset(hover_offset)
    deck_hovered.emit(deck_id)


func _on_mouse_exited() -> void:
    animate_offset(normal_offset)
    deck_hover_end.emit()


func animate_offset(target_offset: Vector2) -> void:
    # kill the previous tween to avoid glitching or stacking
    if tween and tween.is_valid():
        tween.kill()
    
    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_property(self, "offset_transform_position", target_offset, hover_offset_duration)


func _on_gui_input(event: InputEvent) -> void:
    if event.is_action_pressed("LeftClick"):
        deck_clicked.emit(deck_id)
