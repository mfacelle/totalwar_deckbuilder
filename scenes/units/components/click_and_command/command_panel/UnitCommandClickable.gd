class_name UnitCommandClickable
extends Control

# defines a basic signal that can be reported to unit command UI on a click

signal handle_command(command: UnitTypes.Command)

@export_category("Node References")
@export var icon: TextureRect
@export var label: Label

@export_category("Animation Params")
@export var normal_scale: Vector2 = Vector2(1, 1)
@export var hover_scale: Vector2 = Vector2(1.25, 1.25)
@export var show_label_modulate: Color = Color(1,1,1,1)
@export var hidden_label_modulate: Color = Color(0,0,0,0)
@export var hover_anim_duration: float = 0.2


var command: UnitTypes.Command = UnitTypes.Command.DEFAULT

var tween: Tween

func _ready() -> void:
    label.modulate = hidden_label_modulate
    
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)


## will only be clickable if already in the correct state
func _gui_input(event: InputEvent) -> void:
    if event.is_action_pressed("LeftClick"):
        handle_command.emit(command)


# TODO mouse enter/exit signals to scale up object?
# want to do this here but, since it's a base script, do we not have the signals to connect?

func _on_mouse_entered() -> void:
    # set z index so it displays above the other panels
    z_index = 1
    
    if tween and tween.is_valid():
        tween.kill()
    
    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_parallel(true)
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_property(self, "scale", hover_scale, hover_anim_duration)
    tween.set_trans(Tween.TRANS_CIRC)
    tween.tween_property(label, "modulate", show_label_modulate, hover_anim_duration)


func _on_mouse_exited() -> void:
    if tween and tween.is_valid():
        tween.kill()
    
    tween = create_tween()
    tween.set_ease(Tween.EASE_IN)
    tween.set_parallel(true)
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_property(self, "scale", normal_scale, hover_anim_duration)
    tween.set_trans(Tween.TRANS_CIRC)
    tween.tween_property(label, "modulate", hidden_label_modulate, hover_anim_duration)
    tween.set_parallel(false)
    tween.tween_callback(func(): z_index = 0)
