extends Node

# manages data for various decks

# create lists of cards and map them to their deck IDs

# TODO need to add more unit types to actually make these decks usable

# TODO eventually, want to just load this stuff from a config file (csv or something)

# cannot do nested types like Dictionary[type1, Array[type2]], 
# so Dictionary[DeckData.DeckId, Array[CardData.CardId]] won't work.
# just using individual arrays instead
var slime_deck_cards: Array[CardData.CardId] = [
        CardData.CardId.SLIME_BLUE,
        CardData.CardId.SLIME_BLUE,
        CardData.CardId.SLIME_BLUE,
        CardData.CardId.SLIME_BLUE,
        CardData.CardId.SLIME_GREEN,
        CardData.CardId.SLIME_GREEN,
        CardData.CardId.SLIME_GREEN,
        CardData.CardId.SLIME_GREEN
        #CardData.CardId.SLIME_BLUE_BIG,
        #CardData.CardId.SLIME_GREEN_BIG
]

var goblin_deck_cards: Array[CardData.CardId] = [
        CardData.CardId.GOBLIN,
        CardData.CardId.GOBLIN,
        CardData.CardId.GOBLIN,
        CardData.CardId.GOBLIN,
        CardData.CardId.ORC,
        CardData.CardId.ORC
]

var druid_deck_cards: Array[CardData.CardId] = [
        CardData.CardId.WOLF,
        CardData.CardId.WOLF,
        CardData.CardId.WOLF,
        CardData.CardId.WARG,
        CardData.CardId.WARG
]

# create decks and map them to their IDs
# - id
# - name
# - description
# - cardback_texture_uid
# - cards
var decks: Dictionary[DeckData.DeckId, DeckData] = {
    DeckData.DeckId.SLIME: DeckData.new(DeckData.DeckId.SLIME,
        "Goop Deck",
        "Very slimy",
        "uid://32eykhyumbol",
        slime_deck_cards),
    DeckData.DeckId.GOBLIN: DeckData.new(DeckData.DeckId.GOBLIN,
        "Goblin Boyos",
        "WAAAAAAA",
        "uid://cd4eg3nxmaey5",
        goblin_deck_cards),
    DeckData.DeckId.DRUID: DeckData.new(DeckData.DeckId.DRUID,
        "Druid's Deck",
        "A deck that a forest-dwelling Druid would use",
        "uid://c31x8udlkp7de",
        druid_deck_cards)
}
