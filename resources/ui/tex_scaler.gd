@tool
extends StyleBoxTexture

# from:
# https://forum.godotengine.org/t/scaling-styleboxtexture-without-scaling-the-control/134758
# 
# alternate option, but this script has to go on container nodes themselves:
# https://forum.godotengine.org/t/is-there-any-way-to-scale-up-a-ninepatchrect-without-actually-scaling-the-node/63237/3

# this also scales up margins, so things may not be able to be as small as planned

## base texture to use for this element
@export var texture_source: AtlasTexture

## base margin left, from original pixel size
@export var base_margin_left: float
## base margin left, from original pixel size
@export var base_margin_top: float
## base margin left, from original pixel size
@export var base_margin_right: float
## base margin left, from original pixel size
@export var base_margin_bottom: float


## scaling factor for the texture.
## This will modify the texture used by this StyleBoxTexture
@export var texture_scale: int = 1:
    set(value):
        texture_scale = value
        resize(value)
        print("setter called")


## TODO this works, but it modifies the actual StyleBoxTexture itself,
## and converts AtlasTexture into ImageTexture, which means this can't
## be changed easily later just by using a different texture (i.e. change UI colors in game)
##
## TODO would be nice to have a better way to dynamically swap textures and resize them
## during the game.  But this will work for now, just to get things to display right.
## Changing UI theme during gameplay is probably overkill anyway
func resize(scale: int) -> void:
    # if provided, set atlas texture image source
    # TODO this is only really needed if there's a dynamic way to swap textures.
    # this doesn't work for this method...
    #if texture_source:
        #self.texture.atlas = texture_source
    
    print("scaling")
    self.texture_margin_left = self.base_margin_left * scale
    self.texture_margin_top = self.base_margin_top * scale
    self.texture_margin_right = self.base_margin_right * scale
    self.texture_margin_bottom = self.base_margin_bottom * scale
    #var tex: Texture2D = self.texture
    var img: Image = texture_source.get_image()
    var new_size: Vector2i = Vector2i(texture_source.get_size() * scale)
    img.resize(new_size.x, new_size.y, Image.INTERPOLATE_NEAREST)
    self.texture = ImageTexture.create_from_image(img)
