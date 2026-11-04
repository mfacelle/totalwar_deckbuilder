extends Button


@export_category("Animation")
@export var normal_offset: Vector2 = Vector2.ZERO
@export var offscreen_offset: Vector2 = Vector2(0, -1000)
@export var anim_duration: float = 0.5
@export var pause_menu: Control

var battle_state: BattleSignalManager.BattleState
var pause_tween: Tween

func _ready() -> void:
    BattleSignalManager.battle_state_update.connect(_on_battle_state_update)
    pause_menu.visible = false
    pause_menu.offset_transform_position = offscreen_offset


func _on_battle_state_update(new_state: BattleSignalManager.BattleState) -> void:
    battle_state = new_state


## toggle pause, based on current state
## TODO possible to get into weird race conditions with this?
func _on_pressed() -> void:
    if BattleSignalManager.is_running_state(battle_state):
        pause()
    elif battle_state == BattleSignalManager.BattleState.PAUSED:
        unpause()


func pause() -> void:
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.PAUSED)
    print("Pausing game")
    
    # animate pause window coming in
    if pause_tween and pause_tween.is_valid():
        pause_tween.kill()
    
    pause_menu.visible = true
    pause_menu.offset_transform_position = offscreen_offset
    
    pause_tween = create_tween()
    pause_tween.set_ease(Tween.EASE_OUT)
    pause_tween.set_trans(Tween.TRANS_BACK)
    pause_tween.tween_property(pause_menu, "offset_transform_position", normal_offset, anim_duration)



func unpause() -> void:
    # animate pause menu going away
    if pause_tween and pause_tween.is_valid():
        pause_tween.kill()
    
    pause_tween = create_tween()
    pause_tween.set_ease(Tween.EASE_IN)
    pause_tween.set_trans(Tween.TRANS_BACK)
    pause_tween.tween_property(pause_menu, "offset_transform_position", offscreen_offset, anim_duration)
    # after tween finishes, set visible to false so it doesn't obscure main UI buttons
    # wait to resume game until then also
    pause_tween.tween_callback(func(): 
        pause_menu.visible = false
        BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.RUNNING)
        print("Resuming game"))
