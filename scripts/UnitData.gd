class_name UnitData
extends Resource

enum UnitId {
    NONE,
    BASE,
    GOBLIN,
    ORC,
    WILD_ORC,
    WOLF,
    WARG,
    BAT,
    SLIME_BLUE,
    SLIME_GREEN,
    SLIME_BLUE_BIG,
    SLIME_GREEN_BIG
}


## returns the corresponding UnitId for the string name provided.
## intended for reading from config files.
## converts name to lower to prevent case sensitivity issues
static func string_to_unit_id(name: String) -> UnitId:
    match name.to_lower():
        "base":
            return UnitId.BASE
        "goblin":
            return UnitId.GOBLIN
        "orc":
            return UnitId.ORC
        "wild_orc":
            return UnitId.WILD_ORC
        "wolf":
            return UnitId.WOLF
        "warg":
            return UnitId.WARG
        "bat":
            return UnitId.BAT
        "slime_blue":
            return UnitId.SLIME_BLUE
        "slime_green":
            return UnitId.SLIME_GREEN
        "slime_blue_big":
            return UnitId.SLIME_BLUE_BIG
        "slime_green_big":
            return UnitId.SLIME_GREEN_BIG
        _: # default case, just return a goblin
            print("Failed to map string to UnitId: ", name)
            return UnitId.NONE


# TODO consider splitting up some of these params into smaller pieces,
# i.e. attack params, movement params, etc.
# for now, loading everything from one csv is perfectly fine.  it's not that much stuff

## ID, for referencing in code
var id: UnitId
## max health
var max_health: int
## speed of this unit
var speed: int
## damage done by attacks
var attack_damage: int
## range, in pixels, an enemy is considered for attacking
var attack_range: int
## how frequently this unit can attack, in seconds
var attack_delay: float
## duration of attack animation, in seconds (TODO use animation callback instead)
var attack_speed: float
## range, in pixels, to search for nearby targets
var enemy_search_range: int
## how often, in seconds, to periodically search for new targets
var target_search_delay: float
## UID of scene to instantiate for this unit
var unit_scene_uid: String


func _init(_id: UnitId, _max_health: int, _speed: int, 
    _attack_damage: int, _attack_range: int, _attack_delay: float, 
    _attack_speed: float, _enemy_search_range: int, _target_search_delay: float,
    _unit_scene_uid: String):
    id = _id
    max_health = _max_health
    speed = _speed
    attack_damage = _attack_damage
    attack_range = _attack_range
    attack_delay = _attack_delay
    attack_speed = _attack_speed
    enemy_search_range = _enemy_search_range
    target_search_delay = _target_search_delay
    unit_scene_uid = _unit_scene_uid
