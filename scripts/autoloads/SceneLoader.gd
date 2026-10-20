extends Node

# from Queble video: https://www.youtube.com/watch?v=m4PfHg3hmSo
# TODO doesn't quite get what I need here...
# notes:
# - need to be able to load scenes into specific objects within the tree,
#   i.e. UI, maps, transitions

signal progress_changed(progress)
signal load_finished()

var loading_screen: PackedScene = preload("uid://ctmue1buij8b2")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true

func _ready() -> void:
    # disable processing by default
    set_process(false)


func load_scene(_scene_path: String) -> void:
    scene_path = _scene_path
    
    var new_load_screen = loading_screen.instantiate()
    add_child(new_load_screen)
    progress_changed.connect(new_load_screen._on_progress_changed)
    load_finished.connect(new_load_screen._on_load_finished)
    
    await new_load_screen.loading_screen_ready
    
    start_load()


func start_load() -> void:
    var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
    if state == OK:
        set_process(true)


func _process(_delta: float) -> void:
    var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
    progress_changed.emit(progress[0])
    match load_status:
        ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
            set_process(false)
        ResourceLoader.THREAD_LOAD_LOADED:
            loaded_resource = ResourceLoader.load_threaded_get(scene_path)
            # TODO this totally blows away the scene tree. don't want that
            get_tree().change_scene_to_packed(loaded_resource)
            load_finished.emit()
