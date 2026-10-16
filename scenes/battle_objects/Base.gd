class_name Base
extends Unit
# TODO consider just extending from Unit, since it's basically a non-moving unit,
# and we'll likely want to treat it that was for stuff like buffs/debuffs/effects?

## range for valid placement of units, in pixels
@export var placement_range: int

@onready var placement_zone: Area2D = $PlacementZone
@onready var placement_shape: CollisionShape2D = $PlacementZone/CollisionShape2D


func _ready() -> void:
    # only enable animations when game is active (so editor doesn't keep them running)
    #anim_tree.set_active(true)
    
    # set layer used for damage collisions affecting this object
    # TODO this is not great. didn't want to have two separate variable for hit/hurt box types, though
    if entity_type == Unit.EntityType.FRIENDLY:
        hurt_box.set_collision_layer_value(Unit.EntityType.FRIENDLY, true)
    else:
        hurt_box.set_collision_layer_value(Unit.EntityType.ENEMY, true)
    
    # set values for parameters other than default
    health = max_health
    
    placement_shape.shape.radius = placement_range
    set_spawn_area_visible(false)


# override base Unit functionality. nothing to do for these functions

func _physics_process(delta: float) -> void:
    pass


func update_animation() -> void:
    pass

func move(delta: float) -> void:
    pass

func attack() -> void:
    pass


# override base Unit functionality, with differences for this class

## play death animation and destroy object
## TODO need to trigger some kind of failure condition for battle
func die() -> void:
    # TODO do nothing, for now
    print("Base ", name, " destroyed!")
    
    # TODO probably a better way to do this
    if entity_type == Unit.EntityType.FRIENDLY:
        BattleSignalManager.base_destroyed.emit()
    else:
        BattleSignalManager.enemy_base_destroyed.emit()
    
    queue_free()


# functions unique to Base class

## sets visibility of the spawn area
func set_spawn_area_visible(visible: bool) -> void:
    placement_zone.visible = visible
