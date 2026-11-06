class_name UnitTypes

## basic state, for updating entity
enum State
{
    IDLE, ## no objective or movement target
    MOVE, ## actvely moving
    ATTACK, ## actively attacking
    WAITING_ORDERS, ## clicked on, waiting for more
    DEAD, ## dead, about to be deleted (...in most cases?)
    STUCK ## stuck and unable to proceed with movement. TODO not properly implemented
}

## commands that influence behavior of entity
## TODO want to reconsider these and change them
enum Command
{
    ATTACK, ## attack nearest enemy (or specific derived class behavior?)
    DEFEND, ## stay at a point and move to and attack nearby enemies
    HOLD, ## stay at a point and only attack enemies if they enter attack range
    RETREAT ## run base to base
}

# TODO eventually add behavior types (though these may only really apply to enemies?)

## simple behaviors that units can have, for more varied battles
## TODO add unit "behavior" types and actual logic to implement
## TODO can be a list of behaviors maybe? but some conflict with each other
## TODO may want to split this into separate behaviors for attack/defend/hold/retreat
enum BehaviorType
{
    KEEP_ATTACKING, # continue attacking, standard behavior
    DEFEND_THEN_CHASE, # when defending, chase enemies after first encounter
    DEFEND_THEN_HOLD # when defending, return to original spot after first encounter
}

## type of entity, with values matching collision layer ID they will use
enum EntityType
{
    FRIENDLY = 5,
    ENEMY = 6
}
