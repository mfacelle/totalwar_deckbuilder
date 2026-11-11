extends Node

# defines preloads and constants that all units will use.
# defining them here so it isn't painful to add a new component/scene
# that units can use/instantiate at runtime

const ENEMY_SEARCH_AREA_SCENE: PackedScene = preload("uid://crdy2qd2pgc7s")

const COMMAND_LINE_SCENE: PackedScene = preload("uid://7knephbuo65i")
