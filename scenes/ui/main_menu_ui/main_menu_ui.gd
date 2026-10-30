extends Control

## TODO change this to use some kind of dictionary with scene uids for levels/etc
@export_category("Scenes")
## initial map scene to load (TODO eventually load deck/options selection)
@export var start_scene: StringName = &""
## scene containing all battle UI to load (TODO eventually bundle this with map loading?)
@export var battle_ui_scene: StringName = &""

@export_category("Nodes")
@export var start_button: Button


# ---
@export_category("Temporary options text")
## how long to fade in red hurt animation
@export var opt_fadein_duration: float = 0.35
## how long to fade out red hurt animation
@export var opt_fadeout_duration: float = 1.0
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

@export_category("Credits Panel Animation")
## how long to fade in red hurt animation
@export var credits_fadein_duration: float = 0.5
## how long to fade out red hurt animation
@export var credits_fadeout_duration: float = 0.5
## offset of regular position for opt text
@export var credits_target_offset: Vector2 = Vector2(0, 0)
## offset for starting/slide up position for opt text
@export var credits_hide_offset: Vector2 = Vector2(0, 1000.0)
## node for options temp text
@export var credits_panel: Control

var options_tween: Tween
var credits_tween: Tween


func _ready() -> void:
    # hide temporary options text by default
    opt_temp_text.modulate = opt_hide_modulate
    opt_temp_text.offset_transform_position = opt_hide_offset
    
    # ensure credits panel not visible so close button doesn't block inputs
    credits_panel.visible = false
    credits_panel.offset_transform_position = credits_hide_offset


## start the game
## TODO eventually this will launch other scenes
func _on_start_button_pressed() -> void:
    SceneLoader.load_scene(start_scene, SceneLoader.SceneType.WORLD)
    SceneLoader.load_scene(battle_ui_scene, SceneLoader.SceneType.UI)
    
    # on load finished, delete this node
    queue_free()


## display a simple popup text
## TODO eventually have a real menu
func _on_options_button_pressed() -> void:
    if options_tween and options_tween.is_valid():
        options_tween.kill()
    
    opt_temp_text.modulate = opt_hide_modulate
    opt_temp_text.offset_transform_position = opt_hide_offset
    
    # TODO seem to be doing this stuff a lot... probably worth making a script 
    # that handles exactly this.
    # TODO plus, the two tween functions in this class conflict with one another
    options_tween = create_tween()
    options_tween.set_ease(Tween.EASE_OUT)
    options_tween.set_trans(Tween.TRANS_BACK)
    # change visibility and start moving simultaneously
    options_tween.set_parallel(true)
    options_tween.tween_property(opt_temp_text, "offset_transform_position", opt_target_offset, opt_fadein_duration)
    options_tween.tween_property(opt_temp_text, "modulate", opt_display_modulate, opt_fadein_duration)
    options_tween.set_parallel(false)
    # then fade out
    options_tween.set_ease(Tween.EASE_IN)
    options_tween.set_trans(Tween.TRANS_EXPO)
    options_tween.tween_property(opt_temp_text, "modulate", opt_hide_modulate, opt_fadeout_duration)


## make credits panel appear
func _on_credits_button_pressed() -> void:
    if credits_tween and credits_tween.is_valid():
        credits_tween.kill()
    
    credits_panel.visible = true
    credits_panel.offset_transform_position = credits_hide_offset
    
    credits_tween = create_tween()
    credits_tween.set_ease(Tween.EASE_OUT)
    credits_tween.set_trans(Tween.TRANS_BACK)
    credits_tween.tween_property(credits_panel, "offset_transform_position", credits_target_offset, credits_fadein_duration)


## close the window
func _on_credits_close_button_pressed() -> void:
    if credits_tween and credits_tween.is_valid():
        credits_tween.kill()
    
    credits_tween = create_tween()
    credits_tween.set_ease(Tween.EASE_IN)
    credits_tween.set_trans(Tween.TRANS_BACK)
    credits_tween.tween_property(credits_panel, "offset_transform_position", credits_hide_offset, credits_fadeout_duration)
    # after tween finishes, set visible to false so it doesn't obscure main UI buttons
    credits_tween.tween_callback(func(): credits_panel.visible = false)
