class_name Discard
extends Control



var cards: CardPile
var tween: Tween
var card_held: Card = null


## how far to offset the card when hovering over it
@export var hover_offset: Vector2 = Vector2(0.0, 16.0)
## normal offset
@export var normal_offset: Vector2 = Vector2(0.0, 32.0)
## duration of transition for hover offset, in seconds
@export var hover_offset_duration: float = 0.25


func _on_mouse_entered() -> void:
    animate_offset(hover_offset)


func _on_mouse_exited() -> void:
    animate_offset(normal_offset)


func animate_offset(target_offset: Vector2) -> void:
    # kill the previous tween to avoid glitching or stacking
    if tween and tween.is_valid():
        tween.kill()
    
    create_tween()
    tween = get_tree().create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_property(self, "offset_transform_position", target_offset, hover_offset_duration)


## if discard is clicked while a card is held, add it to the discard pile
func _on_gui_input(event: InputEvent) -> void:
    # TODO use proper input handling
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and card_held:
        # adding to discard will be handled by CardUI (probably not the best way, but it works for now)
        BattleSignalManager.card_discarded.emit(card_held)
