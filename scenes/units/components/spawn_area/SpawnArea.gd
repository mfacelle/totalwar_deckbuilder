extends Area2D

## color to draw this area with
@export var spawn_area_color: Color = Color(0.29, 1.0, 0.84, 0.5)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
    
func _draw() -> void:
    draw_circle(position, collision_shape.shape.radius, spawn_area_color)
