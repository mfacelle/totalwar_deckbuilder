extends Node


## indices into csv file, for parsing
enum CsvColumnIndex {
    UNIT_ID = 0,
    MAX_HEALTH,
    SPEED,
    ATTACK_DAMAGE,
    ATTACK_RANGE,
    ATTACK_DELAY,
    ATTACK_SPEED,
    ENEMY_SEARCH_RANGE,
    TARGET_SEARCH_DELAY,
    UNIT_SCENE_UID,
    NUM_FIELDS
}


## path to unit data csv file (can't use UID because it's not imported)
const unit_data_csv_file: String = "res://config/UnitData.csv"

## unit data
var units: Dictionary[UnitData.UnitId, UnitData]


## load unit data on ready
func _ready() -> void:
    units = load_from_config(unit_data_csv_file)
    
    # create null entry for NONE unit id
    # TODO may need a better way to handle this in the future
    units[UnitData.UnitId.NONE] = null


## read csv file and load into a Dictionary
func load_from_config(filepath: String) -> Dictionary[UnitData.UnitId, UnitData]:
    var file := FileAccess.open(filepath, FileAccess.READ)
    if not file:
        print("Unable to load Unit Data csv file from ", filepath)
        return {}
    
    # read off header row, won't be used
    var _header_row := file.get_csv_line()
    
    var all_unit_data: Dictionary[UnitData.UnitId, UnitData] = {}
    
    # read each row into a dictionary entry
    while not file.eof_reached():
        var row := file.get_csv_line()
        
        # skip empty rows (possible trailing empty lines at end?)
        if row.size() < CsvColumnIndex.NUM_FIELDS or row[CsvColumnIndex.UNIT_ID].is_empty():
            continue
        
        var unit_id := UnitData.string_to_unit_id(row[CsvColumnIndex.UNIT_ID])
        var max_health := row[CsvColumnIndex.MAX_HEALTH].to_int()
        var speed := row[CsvColumnIndex.SPEED].to_int()
        var attack_damage := row[CsvColumnIndex.ATTACK_DAMAGE].to_int()
        var attack_range := row[CsvColumnIndex.ATTACK_RANGE].to_int()
        var attack_delay := row[CsvColumnIndex.ATTACK_DELAY].to_float()
        var attack_speed := row[CsvColumnIndex.ATTACK_SPEED].to_float()
        var enemy_search_range := row[CsvColumnIndex.ENEMY_SEARCH_RANGE].to_int()
        var target_search_delay := row[CsvColumnIndex.TARGET_SEARCH_DELAY].to_float()
        var unit_scene_uid := row[CsvColumnIndex.UNIT_SCENE_UID]
        
        # insert into dictionary
        all_unit_data[unit_id] = UnitData.new(unit_id, max_health, speed, attack_damage,
            attack_range, attack_delay, attack_speed, enemy_search_range, target_search_delay,
            unit_scene_uid)
    
    return all_unit_data


func get_unit_scene_uid(unit_id: UnitData.UnitId) -> String:
    return units[unit_id].unit_scene_uid
