extends Control

## TODO change this to use some kind of dictionary with scene uids for levels/etc
@export var start_scene: StringName = &""
@export var card_ui_scene: StringName = &""
@export var battle_controls_ui_scene: StringName = &""
@export var battle_top_bar_ui_scene: StringName = &""
@export var start_button: Button


func _on_start_button_pressed() -> void:
    # TODO need to load it into the appropriate node!
    SceneLoader.load_scene(start_scene, SceneLoader.SceneType.WORLD)
    SceneLoader.load_scene(card_ui_scene, SceneLoader.SceneType.UI)
    SceneLoader.load_scene(battle_controls_ui_scene, SceneLoader.SceneType.UI)
    SceneLoader.load_scene(battle_top_bar_ui_scene, SceneLoader.SceneType.UI)
    
    # TODO on load finished, delete this node?
