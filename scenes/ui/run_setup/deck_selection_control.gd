extends Control


@export_category("Node References")
@export var deck_info: Control
@export var deck_name_label: Label
@export var deck_description_label: Label
@export var deck_cards_preview: HBoxContainer
# TODO add perk info panel stuff
@export var deck_selection_panel: HBoxContainer

@export_category("Info Display Animation")
@export var deckinfo_fade_duration: float = 0.35
@export var deckinfo_display_modulate: Color = Color(1, 1, 1, 1)
@export var deckinfo_hide_modulate: Color = Color(0, 0, 0, 0)

const BASE_DECK_SCENE: PackedScene = preload("uid://bul420d02eiwh")
const BASE_CARD_PREVIEW_SCENE: PackedScene = preload("uid://v42dqxcnxmx1")


## TODO temporary set of decks to display. 
## TODO eventually load this from some kind of player config
var default_decks: Array[DeckData.DeckId] = [
    DeckData.DeckId.SLIME,
    DeckData.DeckId.GOBLIN,
    DeckData.DeckId.DRUID
]

var deckinfo_tween: Tween

func _ready() -> void:
    # set up default decks
    for deck_id in default_decks:
        var deck: DeckSelection = instantiate_deck(deck_id)
        deck.deck_hovered.connect(on_deck_hovered)
        deck.deck_hover_end.connect(on_deck_hover_end)
        deck.deck_clicked.connect(on_deck_chosen)
        deck_selection_panel.add_child(deck)
    
    deck_info.modulate = deckinfo_hide_modulate


## instantiate a deck scene
func instantiate_deck(deck_id: DeckData.DeckId) -> DeckSelection:
    var deck_tmp = BASE_DECK_SCENE.instantiate() as DeckSelection
    deck_tmp.deck_id = deck_id
    return deck_tmp


## fadein deck info and show cards
func on_deck_hovered(deck_id: DeckData.DeckId):
    # get deck info and set info fields
    var deck: DeckData = DeckDataManager.decks[deck_id]
    
    deck_name_label.text = deck.name
    deck_description_label.text = deck.description
    
    # ensure deck cards preview is empty, then populate
    clear_deck_preview()
    for card_id: CardData.CardId in deck.cards:
        var card_tmp = BASE_CARD_PREVIEW_SCENE.instantiate() as DeckPreviewCard
        card_tmp.card_id = card_id
        deck_cards_preview.add_child(card_tmp)
    
    # fadein tween
    if deckinfo_tween and deckinfo_tween.is_valid():
        deckinfo_tween.kill()
    
    deckinfo_tween = create_tween()
    deckinfo_tween.set_ease(Tween.EASE_OUT)
    deckinfo_tween.set_trans(Tween.TRANS_CIRC)
    deckinfo_tween.tween_property(deck_info, "modulate", deckinfo_display_modulate, deckinfo_fade_duration) 


## fadeout deck info
func on_deck_hover_end():
    # fadeout tween
    if deckinfo_tween and deckinfo_tween.is_valid():
        deckinfo_tween.kill()
    
    deckinfo_tween = create_tween()
    deckinfo_tween.set_ease(Tween.EASE_OUT)
    deckinfo_tween.set_trans(Tween.TRANS_CIRC)
    deckinfo_tween.tween_property(deck_info, "modulate", deckinfo_hide_modulate, deckinfo_fade_duration)
    # ensure deck preview cards empty after tween completes
    deckinfo_tween.tween_callback(clear_deck_preview)


## clear all cards from deck preview
func clear_deck_preview() -> void:
    for child in deck_cards_preview.get_children():
        child.queue_free() 


func on_deck_chosen(_deck_id: DeckData.DeckId) -> void:
    SceneLoader.load_battle(SceneConstants.TEST_MAP_SCENE_UID)
