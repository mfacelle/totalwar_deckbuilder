extends Button

var battle_state: BattleSignalManager.BattleState

func _ready() -> void:
    BattleSignalManager.battle_state_update.connect(_on_battle_state_update)


func _on_battle_state_update(new_state: BattleSignalManager.BattleState) -> void:
    battle_state = new_state
    

## toggle pause, based on current state
## TODO possible to get into weird race conditions with this?
func _on_pressed() -> void:
    if BattleSignalManager.is_running_state(battle_state):
        BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.PAUSED)
        print("Pausing game")
    elif battle_state == BattleSignalManager.BattleState.PAUSED:
        BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.RUNNING)
        print("Resuming game")
