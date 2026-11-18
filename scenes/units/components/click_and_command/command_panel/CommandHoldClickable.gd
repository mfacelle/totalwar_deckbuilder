class_name CommandHoldClickable
extends UnitCommandClickable

func _ready() -> void:
    super._ready()
    command = UnitTypes.Command.HOLD
