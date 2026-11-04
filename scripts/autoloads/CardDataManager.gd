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
        "basic goblin description", 
        "uid://c225prpw4bk5x",
        "uid://c04156uo2ffdq"),
    CardData.CardId.ORC: CardData.new(CardData.CardId.ORC,
        CardData.CardType.UNIT,
        "Orc", 
        "uid://sptod5c5wico", 
        "orc description", 
        "uid://c4j4so8syle5l",
        "uid://c04156uo2ffdq"),
    CardData.CardId.WILD_ORC: CardData.new(CardData.CardId.WILD_ORC,
        CardData.CardType.UNIT,
        "Wild Orc", 
        "uid://ceqxrpdahr4ex", 
        "wild orc description", 
        "uid://c0honvmblkmqx",
        "uid://c04156uo2ffdq"),
    CardData.CardId.WOLF: CardData.new(CardData.CardId.WOLF,
        CardData.CardType.UNIT,
        "Wolf", 
        "uid://b3r10ilg3vtxx", 
        "wolf description", 
        "uid://c8k2b2hwehfjr",
        "uid://c04156uo2ffdq"),
    CardData.CardId.WARG: CardData.new(CardData.CardId.WARG,
        CardData.CardType.UNIT,
        "Warg", 
        "uid://wlv42rfvc7r7", 
        "warg description", 
        "uid://b05ig08iqggom",
        "uid://c04156uo2ffdq"),
    CardData.CardId.SLIME_BLUE: CardData.new(CardData.CardId.SLIME_BLUE,
        CardData.CardType.UNIT,
        "Blue Slime", 
        "uid://ci2sc4uywfjr", 
        "blue slime description", 
        "uid://bsby7iejc8bwl",
        "uid://c04156uo2ffdq"),
    CardData.CardId.SLIME_GREEN: CardData.new(CardData.CardId.SLIME_GREEN,
        CardData.CardType.UNIT,
        "Green Slime", 
        "uid://h5v5dbbkaox8", 
        "green slime description", 
        "uid://btjtts0dspsl4",
        "uid://c04156uo2ffdq")
}
