class_name HoldingEnemySearchComponent
extends BasicEnemySearchComponent


# when holding, only allow targets that are within the unit's attack range

var attack_radius: float

## initialize, including an additional attack radius param
func _init(search_area: NearbyEnemySearchAreaComponent, \
search_delay: float, \
group_name: String, \
behavior: UnitTypes.SearchBehavior,
_attack_radius: float):
    super(search_area, search_delay, group_name, behavior)
    attack_radius = _attack_radius


## filter out any enemies that are outside the unit's normal attack range
func filter_enemies(enemy_list: Array[Unit]) -> Array[Unit]:
    return enemy_list.filter( \
        func(enemy: Unit): 
            return global_position.distance_to(enemy.global_position) < attack_radius)
