class_name NearbyEnemySearchAreaComponent
extends Area2D

signal enemy_entered(_unit: Unit)
signal enemy_exited(_unit: Unit)

@export var search_collision_shape: CollisionShape2D

var enemy_type: UnitData.EntityType = UnitData.EntityType.FRIENDLY
var search_radius: int

## set up search area mask and size
func _ready() -> void:
    set_collision_mask_value(enemy_type, true)
    search_collision_shape.shape.radius = search_radius


## report that enemy entered search area, and listen for die signal
func _on_enemy_entered_search_area(area: Area2D) -> void:
    # ensure area's owner is valid
    if area.is_queued_for_deletion() or not area.owner:
        return
    
    print(area.owner.name, " entered search area for ", get_parent().name)
    # ignore units that are dying
    var other_unit = area.owner as Unit
    if other_unit.state != Unit.State.DEAD:
        other_unit.unit_died.connect(_on_unit_die)
        enemy_entered.emit(other_unit)


## report that enemy left search area, and stop listening for die signal
func _on_enemy_exited_search_area(area: Area2D) -> void:
    # ensure area's owner is valid
    if area.is_queued_for_deletion() or not area.owner:
        return
    
    print(area.owner.name, " exited search area for ", get_parent().name)
    var other_unit = area.owner as Unit
    other_unit.unit_died.disconnect(_on_unit_die)
    enemy_exited.emit(other_unit)


## if a unit died while we were tracking it, report that it exited search area
func _on_unit_die(unit: Unit) -> void:
    print(unit.name, " reported dead to ", get_parent().name)
    # TODO what if enemy is null here? is that possible?
    enemy_exited.emit(unit)
