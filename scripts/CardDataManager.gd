extends Node

# contains definitions for Card objects, to be used in-game.

# global card definitions
# TODO notes and changes to make, eventually:
# - load this info from a config file (csv/json?)
# - use a map to store all cards, and fetch based on card name or something?
var cards: Dictionary[CardData.CardType, CardData] = {
    CardData.CardType.GOBLIN: CardData.new("Goblin", 
        "uid://rymgho44sdij", 
        "basic goblin description", 
        "uid://c225prpw4bk5x"),
    CardData.CardType.ORC: CardData.new("Orc", 
        "uid://7y72pw2peg0d", 
        "orc description", 
        "uid://c4j4so8syle5l"),
    CardData.CardType.WILD_ORC: CardData.new("Wild Orc", 
        "uid://bv0an0njttbsl", 
        "wild orc description", 
        "uid://c0honvmblkmqx")
}
