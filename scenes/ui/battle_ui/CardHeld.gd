class_name CardHeld
extends Control

# TODO this is basically just a smaller subset of Card class...
# consider refactoring to make this less clumsy and "change in two places" to manage?

@export_category("Bad Placement Animation")
## how long each movement of the bad placement animation should take
@export var anim_duration: float = 0.1
## ffset of bad placement animation, in pixels
@export var anim_target_offset: Vector2 = Vector2(8.0, 0)
## normal offset position
@export var normal_offset: Vector2 = Vector2(0, 0)
## color modulation for bad placement animation
@export var bad_color: Color = Color(1, 0.25, 0.25, 1)
## standard color modulation
@export var normal_color: Color = Color(1, 1, 1, 1)

@export_category("Parameters")
## offset from top-left corner of cursor
@export var position_offset: Vector2 = Vector2(8.0, 8.0)

@onready var card_data: CardData = CardDataManager.cards[card_id]
@onready var card_background: TextureRect = $CardBackground/TextureRect
@onready var image: TextureRect = $CardDetails/Image

var card_id: CardData.CardId
var tween: Tween

# store mouse position to make cards lag behind mouse slightly
var last_mouse_position: Vector2 = Vector2(0, 0)


func _ready() -> void:
    # set atlas texture, since we want a single sprite from a sprite sheet
    var atlas_texture = AtlasTexture.new()
    atlas_texture.atlas = load(card_data.image_uid)
    # TODO hard-coding for now, should make params in CardData
    atlas_texture.region =  Rect2(8, 8, 16, 16)    
    image.texture = atlas_texture
    
    BattleSignalManager.card_placement_fail.connect(_on_card_placement_fail)


## update the card position, but lag behind the mouse by a frame,
## to make it look like the card is being dragged a bit
func _process(_delta: float) -> void:
    global_position = last_mouse_position
    last_mouse_position = get_global_mouse_position() + position_offset


func _on_card_placement_fail(_card: Card) -> void:
    animate_bad_placement()


func animate_bad_placement() -> void:
    if tween and tween.is_valid():
        tween.kill()
    
    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    # change color and start moving simultaneously
    tween.set_parallel(true)
    tween.tween_property(self, "offset_transform_position", anim_target_offset, anim_duration)
    tween.tween_property(self, "modulate", bad_color, anim_duration)
    tween.set_parallel(false)
    # continue to shake in sequence
    tween.tween_property(self, "offset_transform_position", -anim_target_offset, anim_duration)
    tween.tween_property(self, "offset_transform_position", anim_target_offset, anim_duration)
    tween.tween_property(self, "offset_transform_position", -anim_target_offset, anim_duration)
    # return to normal color/position simultaneously
    tween.set_parallel(true)
    tween.tween_property(self, "offset_transform_position", normal_offset, anim_duration)
    tween.tween_property(self, "modulate", normal_color, anim_duration)
