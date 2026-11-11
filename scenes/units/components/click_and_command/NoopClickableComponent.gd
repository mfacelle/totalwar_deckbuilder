class_name NoopClickableComponent
extends ClickableComponent

func _init(_area: Area2D):
    if _area:
        click_area = _area
        # don't connect any signals

# all operations are noops, but should never be called since signals aren't connected

func _on_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
    pass

func _on_mouse_entered() -> void:
    pass

func _on_mouse_exited() -> void:
    pass
