class_name ClickableComponent
extends Node

signal clicked_on()
signal hover_start()
signal hover_end()

var click_area: Area2D

func _init(_area: Area2D):
    if _area:
        click_area = _area
        click_area.input_event.connect(_on_input_event)
        click_area.mouse_entered.connect(_on_mouse_entered)
        click_area.mouse_exited.connect(_on_mouse_exited)


# TODO need to figure out how to only click on one object, when multiple are in range
# (or maybe multiple click is fine?)

func _on_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
    if _event.is_action_pressed("LeftClick"):
        print(name, " click")
        clicked_on.emit()

func _on_mouse_entered() -> void:
    hover_start.emit()

func _on_mouse_exited() -> void:
    hover_end.emit()
