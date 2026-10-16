class_name CardHeld
extends Control

# TODO this is basically just a smaller subset of Card class...
# consider refactoring to make this less clumsy and "change in two places" to manage?

## base scene to use for held cards (TODO may want to make this more dynamic later)
const BASE_CARD_HELD_SCENE: PackedScene = preload("uid://dd8kcd5vk6my6")

@export_category("Params")
@export var card_id: CardData.CardId

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

@onready var card_data: CardData = CardDataManager.cards[card_id]
@onready var card_background: TextureRect = $CardBackground/TextureRect
@onready var image: TextureRect = $CardDetails/Image

var tween: Tween


func _ready() -> void:
    # set atlas texture, since we want a single sprite from a sprite sheet
    var atlas_texture = AtlasTexture.new()
    atlas_texture.atlas = load(card_data.image_uid)
    # TODO hard-coding for now, should make params in CardData
    atlas_texture.region =  Rect2(8, 8, 16, 16)    
    image.texture = atlas_texture
    
    BattleSignalManager.card_placement_fail.connect(_on_card_placement_fail)


func _process(_delta: float) -> void:
    global_position = get_global_mouse_position()


func _on_card_placement_fail(card: Card) -> void:
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
