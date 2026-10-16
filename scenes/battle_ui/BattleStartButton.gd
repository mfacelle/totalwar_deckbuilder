extends Button

## TODO temporary instructions label
@onready var temp_instructions: Control = $"../../InstructionsControl"

## initialize the battle state and hide this button
func _on_pressed() -> void:
    BattleSignalManager.battle_state_update.emit(BattleSignalManager.BattleState.INIT)
    self.visible = false
    
    # TODO temporary instructions label
    temp_instructions.visible = false
    
