class_name RetreatingEnemySearchComponent
extends BasicEnemySearchComponent

# retreating enemy search does not allow for acquiring targets

## override getting enemy list to always return an empty list
func get_enemy_list() -> Array[Unit]:
    return []
