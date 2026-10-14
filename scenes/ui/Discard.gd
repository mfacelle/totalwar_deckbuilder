class_name Discard
extends Control



var cards: CardPile
var tween: Tween
var card_held: Card = null
var battle_state: BattleSignalManager.BattleState = BattleSignalManager.BattleState.NOT_STARTED
# TODO might make sense to make a state machine for handling paused vs non-paused,
# but we really only care about whether or not battle is paused, so some if checks work for now


## how far to offset the card when hovering over it
@export var hover_offset: Vector2 = Vector2(0.0, 16.0)
## normal offset
@export var normal_offset: Vector2 = Vector2(0.0, 32.0)
## duration of transition for hover offset, in seconds
@export var hover_offset_duration: float = 0.25


# TODO having a real state machine would probably be better than if statements everywhere...

func _on_mouse_entered() -> void:
    if BattleSignalManager.is_running_state(battle_state):
        animate_offset(hover_offset)


func _on_mouse_exited() -> void:
    if BattleSignalManager.is_running_state(battle_state):
        animate_offset(normal_offset)


func animate_offset(target_offset: Vector2) -> void:
    # kill the previous tween to avoid glitching or stacking
    if tween and tween.is_valid():
        tween.kill()
    
    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_property(self, "offset_transform_position", target_offset, hover_offset_duration)


## if discard is clicked while a card is held, add it to the discard pile
func _on_gui_input(event: InputEvent) -> void:
    # TODO use proper input handling
    if event.is_action_pressed("LeftClick") and \
    card_held and \
    BattleSignalManager.is_running_state(battle_state):
        # adding to discard will be handled by CardUI (probably not the best way, but it works for now)
        BattleSignalManager.card_discarded.emit(card_held)
        
        accept_event()
