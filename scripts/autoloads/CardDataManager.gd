extends Node

# contains definitions for Card objects, to be used in-game.

# global card definitions
# - CardId
# - CardType
# - name
# - image uid
# - description
# - unit uid
# - card background ui

# TODO notes and changes to make, eventually:
# - load this info from a config file (csv/json?)
# - add stats instead of description
var cards: Dictionary[CardData.CardId, CardData] = {
    CardData.CardId.GOBLIN: CardData.new(CardData.CardId.GOBLIN,
        CardData.CardType.UNIT,
        "Goblin", 
        "uid://y3a4jkayxnbk", 
        "uid://c04156uo2ffdq",
        UnitData.UnitId.GOBLIN),
    CardData.CardId.ORC: CardData.new(CardData.CardId.ORC,
        CardData.CardType.UNIT,
        "Orc", 
        "uid://sptod5c5wico", 
        "uid://c04156uo2ffdq",
        UnitData.UnitId.ORC),
    CardData.CardId.WILD_ORC: CardData.new(CardData.CardId.WILD_ORC,
        CardData.CardType.UNIT,
        "Wild Orc", 
        "uid://ceqxrpdahr4ex", 
        "uid://c04156uo2ffdq",
        UnitData.UnitId.WILD_ORC),
    CardData.CardId.WOLF: CardData.new(CardData.CardId.WOLF,
        CardData.CardType.UNIT,
        "Wolf", 
        "uid://b3r10ilg3vtxx", 
        "uid://c04156uo2ffdq",
        UnitData.UnitId.WOLF),
    CardData.CardId.WARG: CardData.new(CardData.CardId.WARG,
        CardData.CardType.UNIT,
        "Warg", 
        "uid://wlv42rfvc7r7", 
        "uid://c04156uo2ffdq",
        UnitData.UnitId.WARG),
    CardData.CardId.BAT: CardData.new(CardData.CardId.BAT,
        CardData.CardType.UNIT,
        "Bat", 
        "uid://gcuxtdqqfi0w", 
        "uid://c04156uo2ffdq",
        UnitData.UnitId.BAT),
    CardData.CardId.SLIME_BLUE: CardData.new(CardData.CardId.SLIME_BLUE,
        CardData.CardType.UNIT,
        "Blue Slime", 
        "uid://ci2sc4uywfjr", 
        "uid://c04156uo2ffdq",
        UnitData.UnitId.SLIME_BLUE),
    CardData.CardId.SLIME_GREEN: CardData.new(CardData.CardId.SLIME_GREEN,
        CardData.CardType.UNIT,
        "Green Slime", 
        "uid://h5v5dbbkaox8", 
        "uid://c04156uo2ffdq",
        UnitData.UnitId.SLIME_GREEN)
}
