extends Button

# debug button for reloading the main menu
# though this could be used later for other similar button

@export var main_menu_scene: StringName = &""

## load the main menu scene and clear map and battle UI
func _on_pressed() -> void:
    # clear what is currently loaded for map and UI.
    # these call queue_free, which will wait until the end of the frame to
    # delete the nodes safely, allowing this function to run in full
    SceneLoader.unload_scenes(SceneLoader.SceneType.WORLD)
    SceneLoader.unload_scenes(SceneLoader.SceneType.UI)
    
    # load the main menu scene
    SceneLoader.load_scene(main_menu_scene, SceneLoader.SceneType.UI)
