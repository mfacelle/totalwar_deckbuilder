extends Button



func _on_pressed() -> void:
    # TODO eventually, set this to INIT state (once init state logic is actually created)
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.RUNNING)
    self.visible = false
