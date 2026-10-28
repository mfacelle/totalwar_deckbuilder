class_name ScalableUi
extends Control

# temporary script to test out getting UI to resize properly.
# from: https://forum.godotengine.org/t/is-there-any-way-to-scale-up-a-ninepatchrect-without-actually-scaling-the-node/63237/3

@export var tile_scale: float = 1:
    set(value):
        tile_scale = value
        #_resize_children()
        _resize_child(self)
        
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #_resize_children()
    _resize_child(self)

func _notification(what: int) -> void:
    match what:
        NOTIFICATION_RESIZED:
            #_resize_children()
            _resize_child(self)

func _on_child_entered_tree(node: Node):
    _resize_child(node)
    
func _resize_child(node: Node):
    
    size = size if tile_scale == 0 else Vector2(size.x / tile_scale, size.y / tile_scale)
    scale = Vector2(1, 1) if tile_scale == 0 else Vector2(tile_scale, tile_scale)
    
    if "size" in node and "scale" in node:
        print("resizing")
        node.size = size if tile_scale == 0 else Vector2(size.x / tile_scale, size.y / tile_scale)
        node.scale = Vector2(1, 1) if tile_scale == 0 else Vector2(tile_scale, tile_scale)

#
#func _resize_children():
    #for node in get_children():
        #_resize_child(node)
