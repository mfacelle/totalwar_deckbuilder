extends Control

## TODO change this to use some kind of dictionary with scene uids for levels/etc
@export var start_scene: StringName = &""
@export var start_button: Button


func _on_start_button_pressed() -> void:
    # TODO need to load it into the appropriate node!
    SceneLoader.load_scene(start_scene)
    
    # TODO on load finished, delete this node?
