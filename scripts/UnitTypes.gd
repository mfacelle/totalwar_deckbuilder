class_name UnitTypes

## basic state, for updating entity.
## gets set to the active action the unit is performing
enum State
{
    IDLE, ## no objective or movement target
    MOVE, ## actvely moving
    ATTACK, ## actively attacking
    DEAD, ## dead, about to be deleted (...in most cases?)
    STUCK, ## stuck and unable to proceed with movement. TODO not  implemented
}

## commands that influence what the unit does. likely what unit's state machine would use
enum Command
{
    DEFAULT, ## attack nearest enemy in search range (basically same as DEFEND)
    RAMPAGE, ## attack enemies and ignore commanded positions, with no regard for nearby search area
    #DEFEND, ## stay at a point and move to and attack nearby enemies (same as DEFAULT?)
    HOLD, ## stay at a point and only attack enemies if they enter attack range
    RETREAT, ## run to commanded position, don't engage enemies until there
}


## simple behaviors that units can have, for more varied battles. really only apply to enemies,
## as friendly units will just have DEFAULT behavior (at least for now)
## TODO add unit "behavior" types and actual logic to implement
## TODO can be a list of behaviors maybe? but some conflict with each other
## TODO may want to split this into separate behaviors for attack/defend/hold/retreat
enum BehaviorType
{
    DEFAULT, ## attack nearby enemies, then return to commanded position (all friendly units use this)
    ATTACK_AND_STAY, ## attack nearby enemies, then set it as new commanded position to stay there
    RAMPAGE_AFTER_ATTACK, ## enter rampage command after attacking an enemy
    # TODO these two not implemented; probably redundant:
    #DEFEND_THEN_CHASE, ## when defending, chase enemies after first encounter (same as RAMPAGE_AFTER_ATTACK?)
    #DEFEND_THEN_HOLD, ## when defending, return to original spot after first encounter (same as DEFAULT?)
}


## simple behaviors that units will take when attacking or searching for enemies
enum SearchBehavior
{
    CLOSEST, ## find the closest enemy
    LOWEST_HEALTH, ## find the lowest health enemy
    HIGHEST_HEALTH, ## find the highest health enemy
    BASE_FIRST, ## go straight for enemy base, ignore other enemies
    TARGET_LOCK, ## keep target until they die, then search for a new one
}


## type of entity, with values matching collision layer ID they will use
enum EntityType
{
    FRIENDLY = 5,
    ENEMY = 6
}
