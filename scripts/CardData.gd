class_name CardData
extends Resource

enum CardType {
    GOBLIN,
    ORC,
    WILD_ORC
}

## name of the unit, to be displayed on the card
var card_name: String
## uid of texture to use for card image
## TODO need to figure this part out
var image_uid: String
## description to be displayed on card
## TODO do we really want/need this?
var description: String
## scene to instantiate when creating the unit in-game
var unit_uid: String
    
func _init(_name: String, _img_uid: String, _desc: String, _unit_uid: String):
    card_name = _name
    image_uid = _img_uid
    description = _desc
    unit_uid = _unit_uid
