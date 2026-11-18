extends Node

# utilty functions for convert to/from world and canvas positions

# TODO don't really like this being an autoload that requires nodes to
# register themselves to it, but I don't know a better way (yet!) to make
# this easily and globally accessible to specific nodes that require it.
#
# right now, only UnitCommandPanel actually needs this, but others probably will later.
#
# will likely become especially necessary once the game allows scrolling/dragging the
# subviewport camera around the map

var subviewport_container: SubViewportContainer
var subviewport: SubViewport
var ui_layer: CanvasLayer

## convert a subviewport position to canvas layer position.
## TODO this works for now, but definitely won't handle camera movement or other transforms.
## definitely need to figure out a better way to do this
##
## references (for implementing something better later)
## - https://www.reddit.com/r/godot/comments/1haq9gh/transforming_a_vector2_in_a_2d_subviewport_to/
## - https://www.reddit.com/r/godot/comments/1aq1f0b/how_to_convert_a_2d_world_position_to_a_screen/
## - https://forum.godotengine.org/t/static-function-to-translate-a-position-in-2d-space-to-a-position-on-the-canvaslayer/70485
## - https://www.reddit.com/r/godot/comments/1h2gr0l/transform_coordinates_from_one_canvas_layer_to/
func world_to_canvas_pos(world_pos: Vector2) -> Vector2:
    var canvas_pos := world_pos
    
    # get scaling factor to go from subviewport to subviewportcontainer, then scale position by that
    # this assumes there's no transform between the subviewport and canvas layer (i.e. both full screen, origin at 0,0)
    if subviewport_container.stretch:
        var scale_factor := Vector2(subviewport_container.size) / Vector2(subviewport.size)
        canvas_pos *= scale_factor
        print("world_pos=", world_pos)
        print("scale_factor=", scale_factor)
        print("canvas_pos=", canvas_pos)
    
    # TODO this ends up being slightly off what it should be
    
    return canvas_pos
