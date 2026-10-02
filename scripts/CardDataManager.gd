extends Node

# contains definitions for Card objects, to be used in-game.

# global card definitions
# TODO notes and changes to make, eventually:
# - load this info from a config file (csv/json?)
# - use a map to store all cards, and fetch based on card name or something?
var cards: Dictionary[CardData.CardId, CardData] = {
    CardData.CardId.GOBLIN: CardData.new(CardData.CardId.GOBLIN,
        CardData.CardType.UNIT,
        "Goblin", 
        "uid://rymgho44sdij", 
        "basic goblin description", 
        "uid://c225prpw4bk5x"),
    CardData.CardId.ORC: CardData.new(CardData.CardId.ORC,
        CardData.CardType.UNIT,
        "Orc", 
        "uid://7y72pw2peg0d", 
        "orc description", 
        "uid://c4j4so8syle5l"),
    CardData.CardId.WILD_ORC: CardData.new(CardData.CardId.WILD_ORC,
        CardData.CardType.UNIT,
        "Wild Orc", 
        "uid://bv0an0njttbsl", 
        "wild orc description", 
        "uid://c0honvmblkmqx"),
    CardData.CardId.WOLF: CardData.new(CardData.CardId.WOLF,
        CardData.CardType.UNIT,
        "Wolf", 
        "uid://bgoquugk5hx0q", 
        "wolf description", 
        "uid://c8k2b2hwehfjr"),
    CardData.CardId.WARG: CardData.new(CardData.CardId.WARG,
        CardData.CardType.UNIT,
        "Warg", 
        "uid://cqd7brqjuadmm", 
        "warg description", 
        "uid://b05ig08iqggom")
}
