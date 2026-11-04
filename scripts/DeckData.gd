class_name DeckData
extends Resource

enum DeckId {
    SLIME,
    GOBLIN,
    DRUID
}


## ID of this deck
var id: DeckId
## name of this deck
var name: String
## description for this deck
var description: String
## card back texture to use for this deck
var cardback_texture_uid: String
## default list of cards for this deck
## TODO may need some way to allow players to modify base decks? or don't do that?
var cards: Array[CardData.CardId]
# TODO add base perk associated with this deck


func _init(_id: DeckId, _name: String, _decscription: String, _tex_uid: String, _cards: Array[CardData.CardId]):
    id = _id
    name = _name
    description = _decscription
    cardback_texture_uid = _tex_uid
    cards = _cards


func _to_string() -> String:
    return "DeckData name=%s id=%d [instance=%d]" % \
    [name, id, get_instance_id()]
