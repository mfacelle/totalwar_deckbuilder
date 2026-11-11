class_name UnitTypes

## basic state, for updating entity.
## gets set to the active action the unit is performing
enum State
{
    IDLE, ## no objective or movement target
    MOVE, ## actvely moving
    ATTACK, ## actively attacking
    DEAD, ## dead, about to be deleted (...in most cases?)
    STUCK, ## stuck and unable to proceed with movement. TODO not properly implemented
}

## commands that influence behavior of entity. likely what unit's state machine would use
## TODO want to reconsider these and change them
enum Command
{
    DEFAULT, ## attack nearest enemy in search range (basically same as DEFEND)
    RAMPAGE, ## attack enemies and ignore commanded positions, with no regard for nearby search area
    #DEFEND, ## stay at a point and move to and attack nearby enemies (same as DEFAULT?)
    HOLD, ## stay at a point and only attack enemies if they enter attack range TODO probably only used by base?
    RETREAT, ## run to commanded position, don't engage enemies until there
}

# TODO eventually add behavior types (though these may only really apply to enemies?)

## simple behaviors that units can have, for more varied battles. really only apply to enemies
## TODO add unit "behavior" types and actual logic to implement
## TODO can be a list of behaviors maybe? but some conflict with each other
## TODO may want to split this into separate behaviors for attack/defend/hold/retreat
enum BehaviorType
{
    DEFAULT, # nothing special, just follow command (use for friendly units)
    RAMPAGE_AFTER_ATTACK, # enter rampage command after attacking an enemy
    KEEP_ATTACKING, # continue attacking, standard behavior
    DEFEND_THEN_CHASE, # when defending, chase enemies after first encounter
    DEFEND_THEN_HOLD, # when defending, return to original spot after first encounter
}

## type of entity, with values matching collision layer ID they will use
enum EntityType
{
    FRIENDLY = 5,
    ENEMY = 6
}
