extends Button

## initialize the battle state and hide this button
func _on_pressed() -> void:
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.INIT)
    self.visible = false
