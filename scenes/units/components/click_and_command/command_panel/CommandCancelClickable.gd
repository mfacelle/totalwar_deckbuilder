class_name CommandCancelClickable
extends UnitCommandClickable

func _ready() -> void:
    super._ready()
    command = UnitTypes.Command.CANCEL
