extends PanelContainer

@export_category("Text")
@export var victory_text: String = "VICTORY"
@export var defeat_text: String = "DEFEAT"

@export_category("Animation")
@export var normal_offset: Vector2 = Vector2.ZERO
@export var offscreen_offset: Vector2 = Vector2(0, 1000)
@export var anim_duration: float = 0.5

@onready var result_label: Label = $VictoryDefeatLabel

var tween: Tween

func _ready() -> void:
    visible = false
    BattleSignalManager.battle_state_update.connect(_on_battle_state_update)


func _on_battle_state_update(state: BattleSignalManager.BattleState) -> void:
    if state == BattleSignalManager.BattleState.END_VICTORY:
        result_label.text = victory_text
        animate_appear()
    elif state == BattleSignalManager.BattleState.END_DEFEAT:
        result_label.text = defeat_text
        animate_appear()


func animate_appear() -> void:
    if tween and tween.is_valid():
        tween.kill()
    
    offset_transform_position = offscreen_offset
    visible = true
    
    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_property(self, "offset_transform_position", normal_offset, anim_duration)
