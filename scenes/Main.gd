extends Control

@export_category("Node References")
@export var subviewport_container: SubViewportContainer
@export var subviewport: SubViewport
@export var ui_layer: CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    ScreenPositionUtility.subviewport_container = subviewport_container
    ScreenPositionUtility.subviewport = subviewport
    ScreenPositionUtility.ui_layer = ui_layer
