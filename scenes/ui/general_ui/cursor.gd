extends Control

# autoload script for managing cursor image

## enable to display the real mouse (mainly useful for editor stuff)
@export var display_real_cursor: bool = false

## reference to TextureRect node
@export var cursor_image: TextureRect

## image to display for standard cursor
@export var cursor_normal: Texture2D
## image to display when clicking mouse
@export var cursor_click: Texture2D

# TODO: cursor image is being scaled up correctly, but 
# I'm not sure what I actually set to make this happen...

func _ready() -> void:
    # hide the hardware cursor
    if not display_real_cursor:
        Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    
    # set cursor default image
    cursor_image.texture = cursor_normal


## set position to current mouse position
## this will lag the cursor by a frame, but it's not noticeable with the real cursor hidden
func _process(_delta: float) -> void:
    global_position = get_viewport().get_mouse_position()


## set cursor clicked image on clicks
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("LeftClick"):
        cursor_image.texture = cursor_click
    if event.is_action_released("LeftClick"):
        cursor_image.texture = cursor_normal
