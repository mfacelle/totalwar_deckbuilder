class_name HealthComponent
extends Node

signal health_changed(_old_value: int, _new_value: int)
signal died()

var max_health: int
var current_health: int

func _init(_max_health: int):
    max_health = _max_health
    current_health = _max_health


func damage(amount: int) -> void:
    var old_health_value: int = current_health
    current_health = max(0, current_health - amount)
    # if health transitioned to 0
    if current_health <= 0 and old_health_value > 0:
        died.emit()
    else:
        health_changed.emit(old_health_value, current_health)


func heal(amount: int) -> void:
    var old_health_value: int = current_health
    # TODO consider overheal option at some point
    current_health = min(max_health, current_health + amount)
    
    health_changed.emit(old_health_value, current_health)
