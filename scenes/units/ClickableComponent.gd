class_name ClickableComponent
extends Node

signal clicked_on()

var click_area: Area2D

func _init(_area: Area2D):
    if _area:
        click_area = _area
        click_area.input_event.connect(_on_input_event)


## handle click events
## TODO need to figure out how to only click on one object, when multiple are in range
## (or maybe multiple click is fine?)
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
    if event.is_action_pressed("LeftClick"):
        clicked_on.emit()
