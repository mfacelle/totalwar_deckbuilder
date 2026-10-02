class_name CardData
extends Resource

## individual card IDs, for ease of access and identifying
## TODO consider storing somewhere else, this list may get long (CardDataManager?)
enum CardId {
    GOBLIN,
    ORC,
    WILD_ORC,
    WOLF,
    WARG,
    BAT
}

## types of card, for determing how to handle effects when played
enum CardType {
    UNIT,  ## spawns a unit
    SPELL,  ## creates a spell
    EFFECT  ## creates a buff/debuff effect
}


## ID of this card
var card_id: CardId
## type of this card
var card_type: CardType
## name of the unit, to be displayed on the card
var card_name: String
## uid of texture to use for card image
## TODO may want to add params for atlas textures? or just always use single-image texture?
var image_uid: String
## description to be displayed on card
## TODO do we really want/need this?
var description: String
## scene to instantiate when creating the unit in-game
var unit_uid: String

# TODO eventually want to add stuff like:
# - card background texture (i.e. different colors, different types of cards)
# - card outline/border?
# - effects, i.e. shine, color overlay, etc

func _init(_id: CardId, _type: CardType, _name: String, _img_uid: String, _desc: String, _unit_uid: String):
    card_id = _id
    card_type = _type
    card_name = _name
    image_uid = _img_uid
    description = _desc
    unit_uid = _unit_uid
