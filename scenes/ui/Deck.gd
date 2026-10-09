class_name Deck
extends Control

var cards: CardPile
var tween: Tween
var is_hand_full: bool
var battle_state: BattleSignalManager.BattleState = BattleSignalManager.BattleState.NOT_STARTED
# TODO might make sense to make a state machine for handling paused vs non-paused,
# but we really only care about whether or not battle is paused, so some if checks work for now

# TODO the offset animation stuff is the same code (different values) for deck/discard/card.
# should consider refactoring into some kind of base class or something.
# leaving for now, for simplicity

## how far to offset the card when hovering over it
@export var hover_offset: Vector2 = Vector2(0.0, -32.0)
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

@onready var top_card: Container = $TopCard

# TODO want to find a way to hide the "additional" cards when deck size gets too small
# TODO could just @onready them here and check size and set visible, but that feels... bad


func _on_mouse_entered() -> void:
    if battle_state == BattleSignalManager.BattleState.RUNNING:
        animate_topcard_offset(hover_offset)


func _on_mouse_exited() -> void:
    if battle_state == BattleSignalManager.BattleState.RUNNING:
        animate_topcard_offset(normal_offset)


func animate_topcard_offset(target_offset: Vector2) -> void:
    # kill the previous tween to avoid glitching or stacking
    if tween and tween.is_valid():
        tween.kill()
    
    create_tween()
    tween = get_tree().create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_property(top_card, "offset_transform_position", target_offset, hover_offset_duration)



## when deck is clicked, if hand has free space, draw a card
## and play brief animation using tweens
func _on_gui_input(event: InputEvent) -> void:
    # TODO use proper input handling
    if event is InputEventMouseButton and \
    event.button_index == MOUSE_BUTTON_LEFT and \
    event.pressed and \
    battle_state == BattleSignalManager.BattleState.RUNNING:
        if cards.is_empty():
            print("deck is empty, not drawing card")
            # TODO play different animation to show that card was not drawn, like a brief shake or something
            # probably want a different effect than when hand is full
        if is_hand_full:
            print("hand full, not drawing card")
            # TODO play different animation to show that card was not drawn, like a brief shake or something
        else: 
            # hand has room, a card can be drawn
            
            # TODO this isn't the best effect, but it'll work for now.
            # TODO likely want to tween position/offset to slide the card over to the right position at runtime
            # kill previous tween if it's already running to avoid conflicts
            if tween and tween.is_running():
                tween.kill()
            
            tween = create_tween()
            # scale down, then back. keep pivot at center to keep card centered
            top_card.pivot_offset = top_card.size / 2.0
            tween.set_ease(Tween.EASE_OUT)
            tween.set_trans(Tween.TRANS_BACK)
            tween.tween_property(top_card, "scale", click_scale, click_duration)
            tween.tween_property(top_card, "scale", normal_scale, click_duration)
            
            # get top card from deck
            var drawn_card: CardData = cards.draw()
            # redundant check, in case deck was empty
            if drawn_card:
                BattleSignalManager.card_drawn.emit(drawn_card)
