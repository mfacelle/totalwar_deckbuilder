extends Node


# TODO eventually load all this stuff from a config file (csv or something)
# fields:
# - max_health
# - speed
# - attack_damage
# - attack_range
# - attack_delay
# - attack_speed
# - search radius
# - target search delay
var units: Dictionary[UnitData.UnitId, UnitData] = {
    UnitData.UnitId.BASE: UnitData.new(UnitData.UnitId.BASE,
        120, 0, 0, 0, 0, 0, 30, 1.0 ),
    UnitData.UnitId.GOBLIN: UnitData.new(UnitData.UnitId.GOBLIN,
        30, 20, 10, 6, 1.0, 0.5, 30, 1.0  ),
    UnitData.UnitId.ORC: UnitData.new(UnitData.UnitId.ORC,
        40, 15, 12, 6, 1.0, 0.5, 30, 1.0  ),
    UnitData.UnitId.WILD_ORC: UnitData.new(UnitData.UnitId.WILD_ORC,
        40, 20, 12, 6, 1.0, 0.5, 30, 1.0  ),
    UnitData.UnitId.WOLF: UnitData.new(UnitData.UnitId.WOLF,
        25, 40, 8, 6, 0.5, 0.5, 30, 1.0  ),
    UnitData.UnitId.WARG: UnitData.new(UnitData.UnitId.WARG,
        30, 30, 15, 10, 1.5, 0.5, 30, 1.0  ),
    UnitData.UnitId.BAT: UnitData.new(UnitData.UnitId.BAT,
        30, 30, 8, 6, 0.5, 1.0, 30, 1.0  ),
    UnitData.UnitId.SLIME_BLUE: UnitData.new(UnitData.UnitId.SLIME_BLUE,
        40, 12, 8, 6, 1.5, 0.5, 30, 1.0  ),
    UnitData.UnitId.SLIME_GREEN: UnitData.new(UnitData.UnitId.SLIME_GREEN,
        20, 25, 5, 6, 0.5, 0.5, 30, 1.0  ),
    UnitData.UnitId.SLIME_BLUE_BIG: UnitData.new(UnitData.UnitId.SLIME_BLUE_BIG,
        80, 10, 10, 8, 1.5, 0.5, 30, 1.0  ),
    UnitData.UnitId.SLIME_GREEN_BIG: UnitData.new(UnitData.UnitId.SLIME_GREEN_BIG,
        60, 20, 10, 8, 1.5, 0.5, 30, 1.0  ),
}
