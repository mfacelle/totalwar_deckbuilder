class_name BasicEnemySearchComponent
extends Node2D


## inner data structure to use when searching for enemies
class UnitSearchData:
    ## the unit itself
    var unit: Unit
    ## distance to this unit
    var distance: float
    
    func _init(_unit: Unit, _distance: float):
        unit = _unit
        distance = _distance



# base class logic for searching for nearby enemies.
# uses the provided search area and finds the closest enemy

signal new_target_enemy(enemy: Unit)


## list of nearby enemies to search through
var nearby_enemies: Array[Unit]
## current target enemy, for checking if updated
var current_target: UnitSearchData = null
## how frequently, in seconds, to search for new targets
var target_update_delay: float
## current timer counting up to next target search time
var target_update_timer: float
## name of group used to find enemies
var enemy_group_name: String
## method to use when searching for enemies
var search_behavior: UnitTypes.SearchBehavior


## initialize, using the provided search area to register for signals
func _init(search_area: NearbyEnemySearchAreaComponent, \
search_delay: float, \
group_name: String, \
behavior: UnitTypes.SearchBehavior):
    search_area.enemy_entered.connect(_on_enemy_entered_search_area)
    search_area.enemy_exited.connect(_on_enemy_exited_search_area)
    target_update_delay = search_delay
    # start off at half the target search delay, so initial wait isn't as long
    target_update_timer = target_update_delay / 2.0
    enemy_group_name = group_name
    search_behavior = behavior


## add to list of nearby enemies
func _on_enemy_entered_search_area(_unit: Unit) -> void:
    nearby_enemies.append(_unit)


## remove from list of nearby enemies
func _on_enemy_exited_search_area(_unit: Unit) -> void:
    # TODO need to figure out how references are handled in godot...
    nearby_enemies.erase(_unit)


## tick up the timer, and search for a new target if it's time
func _physics_process(delta: float) -> void:
    target_update_timer += delta
    
    if target_update_timer >= target_update_delay:
        target_update_timer = 0
        find_best_enemy()


# consider making this a utility function in a separate script (maybe even C++)
# TODO notes on this:
# - use nav mesh to find closest, not just straight distance
# - use "target points"
# - make more modular/flexible/generic to allow easy overrides
func find_best_enemy() -> void:
    var closest_enemy: UnitSearchData = null
    
    # TODO distance needs to account for nav mesh.
    # TODO need to provide nav mesh to this class
    var enemy_list: Array[Unit] = get_enemy_list()
    filter_enemies(enemy_list)
    for enemy: Unit in enemy_list:
        # TODO will global_position be set properly here?
        var distance = global_position.distance_to(enemy.global_position)
        var current_enemy: UnitSearchData = UnitSearchData.new(enemy, distance)
        # if we don't have a current target, or the new one is better
        if not closest_enemy or is_better_enemy_candidate(closest_enemy, current_enemy):
            closest_enemy = current_enemy
    
    # if we have a new target, emit the signal
    # (could emit every time regardless, but it's unnecessary)
    if current_target != closest_enemy:
        current_target = closest_enemy
        # TODO null checks here are kind of clunky, but necessary
        if not current_target:
            new_target_enemy.emit(null)
        else:
            new_target_enemy.emit(current_target.unit)


## default behavior for list of potential enemies is to only use nearby enemy list
func get_enemy_list() -> Array[Unit]:
    return nearby_enemies


## perform optional filtering on list of enemies.
## directly modifies argument passed in (Array will be a reference)
func filter_enemies(enemy_list: Array[Unit]) -> void:
    # TODO normal search should prioritize enemies over the base,
    # to avoid having units get killed for kind of no reason
    
    # only perform filtering for base first behavior types
    if search_behavior == UnitTypes.SearchBehavior.BASE_FIRST:
        enemy_list.filter(func(enemy: Unit): return enemy is Base)


## checks if the  second unit provided is a better enemy candidate than the first.
## default behavior is to only check for a closer distance.
## TODO consider making this into a separate component if it gets too complex
func is_better_enemy_candidate(unit: UnitSearchData, other_unit: UnitSearchData) -> bool:
    match search_behavior:
        UnitTypes.SearchBehavior.CLOSEST, UnitTypes.SearchBehavior.BASE_FIRST:
            return other_unit.distance < unit.distance
        UnitTypes.SearchBehavior.LOWEST_HEALTH:
            return other_unit.health_component.current_health < unit.health_component.current_health
        UnitTypes.SearchBehavior.HIGHEST_HEALTH:
            return other_unit.health_component.current_health > unit.health_component.current_health
        UnitTypes.SearchBehavior.TARGET_LOCK:
            return false
        _: # distance by default
            return other_unit.distance < unit.distance
