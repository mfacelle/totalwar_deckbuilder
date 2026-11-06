class_name UnitData
extends Resource

enum UnitId {
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

## type of entity, with values matching collision layer ID they will use
enum EntityType
{
    FRIENDLY = 5,
    ENEMY = 6
}


# TODO consider splitting up some of these params into smaller pieces,
# i.e. attack params, movement params, etc.
# could even go along with breaking up node structure for unit scenes themselves

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

func _init(_id: UnitId, _max_health: int, _speed: int, 
    _attack_damage: int, _attack_range: int, _attack_delay: float, _attack_speed: float):
    id = _id
    max_health = _max_health
    speed = _speed
    attack_damage = _attack_damage
    attack_range = _attack_range
    attack_delay = _attack_delay
    attack_speed = _attack_speed
