class_name Base
extends Unit
# TODO consider just extending from Unit, since it's basically a non-moving unit,
# and we'll likely want to treat it that was for stuff like buffs/debuffs/effects?

@export_category("Parameters")
## range for valid placement of units, in pixels
@export var placement_range: int

@export_category("Node References")
@export var placement_zone: Area2D
@export var placement_shape: CollisionShape2D


func _ready() -> void:
    super._ready()
    
    # doesn't really matter if this is set, but doing it anyway
    command = UnitTypes.Command.HOLD
    
    placement_shape.shape.radius = placement_range
    set_spawn_area_visible(false)


# override base Unit functionality. nothing to do for these functions

func _physics_process(_delta: float) -> void:
    pass

func update_animation() -> void:
    pass

func move(_delta: float) -> void:
    pass

func attack() -> void:
    pass


# override base Unit functionality, with differences for this class

## play death animation and destroy object
## TODO need a better way to trigger victory/defeat conditions for battle.
## TODO what if player or enemy has multiple bases? what about other win conditions?
func on_die() -> void:
    print("Base ", name, " destroyed!")
    
    state = UnitTypes.State.DEAD
    if entity_type == UnitTypes.EntityType.FRIENDLY:
        BattleSignalManager.defeat.emit()
    else:
        BattleSignalManager.victory.emit()
    
    queue_free()


# functions unique to Base class

## sets visibility of the spawn area
func set_spawn_area_visible(spawn_visible: bool) -> void:
    placement_zone.visible = spawn_visible
