extends Control

## TODO change this to use some kind of dictionary with scene uids for levels/etc
@export_category("Scenes")
@export var start_scene: StringName = &""
@export var card_ui_scene: StringName = &""
@export var battle_controls_ui_scene: StringName = &""
@export var battle_top_bar_ui_scene: StringName = &""

@export_category("Nodes")
@export var start_button: Button


# ---
@export_category("Temporary options text")
## how long to fade in red hurt animation
@export var opt_fadein_duration: float = 0.35
## how long to fade out red hurt animation
@export var opt_fadeout_duration: float = 2.0
## color modulation for bad placement animation
@export var opt_display_modulate: Color = Color(1, 1, 1, 1)
## standard color modulation
@export var opt_hide_modulate: Color = Color(0, 0, 0, 0)
## offset of regular position for opt text
@export var opt_target_offset: Vector2 = Vector2(0, 0)
## offset for starting/slide up position for opt text
@export var opt_hide_offset: Vector2 = Vector2(0, 100.0)
## node for options temp text
@export var opt_temp_text: Control
# ---

var tween: Tween


func _ready() -> void:
    # hide temporary options text by default
    opt_temp_text.modulate = opt_hide_modulate
    opt_temp_text.offset_transform_position = opt_hide_offset


## start the game
## TODO eventually this will launch other scenes
func _on_start_button_pressed() -> void:
    SceneLoader.load_scene(start_scene, SceneLoader.SceneType.WORLD)
    SceneLoader.load_scene(card_ui_scene, SceneLoader.SceneType.UI)
    SceneLoader.load_scene(battle_controls_ui_scene, SceneLoader.SceneType.UI)
    SceneLoader.load_scene(battle_top_bar_ui_scene, SceneLoader.SceneType.UI)
    
    # on load finished, delete this node
    queue_free()


## display a simple popup text
## TODO eventually have a real menu
func _on_options_button_pressed() -> void:
    if tween and tween.is_valid():
        tween.kill()
    
    opt_temp_text.modulate = opt_hide_modulate
    opt_temp_text.offset_transform_position = opt_hide_offset
    
    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    # change color and start moving simultaneously
    tween.set_parallel(true)
    tween.tween_property(opt_temp_text, "offset_transform_position", opt_target_offset, opt_fadein_duration)
    tween.tween_property(opt_temp_text, "modulate", opt_display_modulate, opt_fadein_duration)
    tween.set_parallel(false)
    tween.set_ease(Tween.EASE_IN)
    tween.set_trans(Tween.TRANS_EXPO)
    tween.tween_property(opt_temp_text, "modulate", opt_hide_modulate, opt_fadeout_duration)
