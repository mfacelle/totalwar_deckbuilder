class_name Base
extends CharacterBody2D

## faction that this entity belongs to (determines what damage collision layers to use)
@export var entity_type: Unit.EntityType = Unit.EntityType.FRIENDLY
## how much health this base can have
@export var max_health: int
## range for valid placement of units, in pixels
@export var placement_range: int

var health: int = max_health

@onready var hurt_box: Area2D = $HurtBox
@onready var sprite = $Sprite2D
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


## play death animation and destroy object
## TODO need to trigger some kind of failure condition for battle
func die() -> void:
    # TODO do nothing, for now
    print("Base ", name, " destroyed!")
    queue_free()


func take_damage(damage: int) -> void:
    print(name, " taking damage")
    health -= damage
    if health <= 0:
        die()
    
    # tint sprite to show damage effect
    sprite.modulate = Color(1, 0, 0, 1) 
    
    # create simple timer to modulate sprite back to normal
    get_tree().create_timer(0.2).timeout.connect(func():
        sprite.modulate = Color(1, 1, 1, 1)
    )
