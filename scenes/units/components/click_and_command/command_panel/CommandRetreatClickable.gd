class_name CommandRetreatClickable
extends UnitCommandClickable

func _ready() -> void:
    super._ready()
    command = UnitTypes.Command.RETREAT
