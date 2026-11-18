class_name RampagingEnemySearchComponent
extends BasicEnemySearchComponent

# rampaging enemy search ignore nearby enemies and instead
# just finds the closest/best enemy, regardless of range

# use base class _init. We still want to maintain nearby enemy list,
# in case enemy search type changes during gameplay


## use nearby enemy list first but, if none are found, use entire list of enemies.
## TODO eventually need to expand this so we can use things other than just distance here
func get_enemy_list() -> Array[Unit]:
    # if we have nearby enemies, return this list
    if not nearby_enemies.is_empty():
        return nearby_enemies
    
    # only look outside normal enemy search area if none were found nearby
    
    var enemy_list: Array[Unit]
    
    # TODO this feels clunky... but need to get enemies as Unit types manually
    var enemy_nodes: Array[Node] = get_tree().get_nodes_in_group(enemy_group_name)
    for enemy_node in enemy_nodes:
        var enemy_unit: Unit = enemy_node as Unit
        enemy_list.append(enemy_unit)
    
    return enemy_list
