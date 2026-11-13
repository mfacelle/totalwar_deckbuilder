class_name Card
extends Control

@export_category("Node References")
## base node for the card, for showing/hiding without changing hand container
@export var card_node: Control
@export var card_background: TextureRect
# TODO these will be used eventually
#@export var card_border: TextureRect
#@export var card_detail_boxes: TextureRect
@export var name_label: Label
@export var image: TextureRect
@export var hp_label: Label
@export var attack_label: Label
@export var speed_label: Label
@export var bonus_label: Label

@export_category("Animation Params")
## id of this card, for creating objects
@export var card_id: CardData.CardId
## how far to offset the card when hovering over it
@export var hover_offset: Vector2 = Vector2(0.0, -64.0)
## normal offset
@export var normal_offset: Vector2 = Vector2(0.0, 0.0)
## duration of transition for hover offset, in seconds
@export var hover_offset_duration: float = 0.25

@onready var card_data: CardData = CardDataManager.cards[card_id]
@onready var unit_scene: PackedScene = load(UnitDataManager.get_unit_scene_uid(card_data.unit_id))

var card_highlighted: bool = false
var card_held: Card = null
var tween: Tween
var battle_state: BattleSignalManager.BattleState = BattleSignalManager.BattleState.NOT_STARTED
# TODO might make sense to make a state machine for handling paused vs non-paused,
# but we really only care about whether or not battle is paused, so some if checks work for now

func _ready() -> void:
    # set up fields on the card from CardData
    name_label.text = card_data.card_name
    # TODO get card values from config
    hp_label.text = "30"
    attack_label.text = "10"
    speed_label.text = "30"
    bonus_label.text = ""
    card_background.texture = load(card_data.card_bg_uid)
    image.texture = load(card_data.image_uid)



func _on_mouse_entered() -> void:
    if BattleSignalManager.is_card_interactable_state(battle_state):
        animate_offset(hover_offset)
        card_highlighted = true
    

func _on_mouse_exited() -> void:
    if BattleSignalManager.is_card_interactable_state(battle_state):
        animate_offset(normal_offset)
        card_highlighted = false


func animate_offset(target_offset: Vector2) -> void:
    # Kill the previous tween to avoid glitching or stacking
    if tween and tween.is_valid():
        tween.kill()
    
    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_property(self, "offset_transform_position", target_offset, hover_offset_duration)


## when card is selected, allow for holding it to be played
func _on_gui_input(event: InputEvent) -> void:
    if event.is_action_pressed("LeftClick") and \
    BattleSignalManager.is_card_interactable_state(battle_state):
        if card_held == self:
            # if this card is currently held, and this original spot is selected again, put it back (by unhiding it)
            card_node.show()
            
            # set card held to null to avoid some kind of weird race condition with signal
            card_held = null
            BattleSignalManager.card_held.emit(null)
            
        elif card_highlighted and not card_held:
            # if this card is selected (highlighted) and we're not currently holding another card, allow holding this one
            # temporarily hide card from UI, but keep it in place in container
            # TODO consider making transparent (and show background only?), so it's clear where to place the card back
            card_node.hide()
            
            # TODO add a "card swap" mechanism, to swap held cards if another is selected.
            # replace card held with card being selected. basically allows reordering of hand (not really necessary, but cool)
            
            # don't update held card until signal is processed, to avoid weird race condition or multiple rapid inputs
            BattleSignalManager.card_held.emit(self)
        
        accept_event()
