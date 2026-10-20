extends Node

# from Queble video: https://www.youtube.com/watch?v=m4PfHg3hmSo
# TODO doesn't quite get what I need here...
# notes:
# - need to be able to load scenes into specific objects within the tree,
#   i.e. UI, maps, transitions, data


signal progress_changed(progress)

signal load_finished()

## types of scenes, which determine what node to place them into
enum SceneType {
    WORLD,
    UI,
    TRANSITION
}

#@onready var world_node: Node = get_node(SceneConstants.WORLD_NODE_PATH)
#@onready var ui_node: Node = get_node(SceneConstants.UI_NODE_PATH)
#@onready var transitions_node: Node = get_node(SceneConstants.TRANSITIONS_UI_NODE_PATH)
@onready var scene_parents: Dictionary[SceneType, String] = {
    SceneType.WORLD: SceneConstants.WORLD_NODE_PATH,
    SceneType.UI: SceneConstants.UI_NODE_PATH
}

## loading screen scene
## TODO may not always want this, i.e. if loading just a map or something?
var loading_screen: PackedScene = preload("uid://ctmue1buij8b2")

## path to scene to be loaded, mapped to their target nodes
var loading_requests: Dictionary[String, Node] = {}
## progress returned by load functions
var progress: Array = []
## option to use sub threads
var use_sub_threads: bool = true

func _ready() -> void:
    # disable processing by default
    set_process(false)


## loads a scene, provided it fits a specific scene type.
## scene type determines what node in the tree it will be loaded into
## TODO consider taking in an array/map of scenes to load all at once, instead of multiple function calls
func load_scene(scene_path: String, scene_type: SceneType) -> void:
    loading_requests[scene_path] = get_node(scene_parents[scene_type])
    
    print("loading scene=", scene_path, "; target=", loading_requests[scene_path] )
    
    # TODO disabling loading screen for now
    #var new_load_screen = loading_screen.instantiate()
    #add_child(new_load_screen)
    #progress_changed.connect(new_load_screen._on_progress_changed)
    #load_finished.connect(new_load_screen._on_load_finished)
    #
    #await new_load_screen.loading_screen_ready
    
    var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
    if state == OK:
        set_process(true)


#func _process(_delta: float) -> void:
    #var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
    #progress_changed.emit(progress[0])
    #match load_status:
        #ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
            #set_process(false)
        #ResourceLoader.THREAD_LOAD_LOADED:
            #loaded_resource = ResourceLoader.load_threaded_get(scene_path)
            ## TODO this totally blows away the scene tree. don't want that
            #get_tree().change_scene_to_packed(loaded_resource)
            #load_finished.emit()


## handle loading requested scenes
## TODO send signal when all scenes have been loaded.
## TODO handle instantiation of all scenes once they're all loaded
func _process(_delta: float) -> void:
    if loading_requests.is_empty():
        set_process(false)
        return
    
    var completed_paths: Array[String] = []
    
    for scene_path in loading_requests.keys():
        var progress: Array = []
        var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
        
        match status:
            ResourceLoader.THREAD_LOAD_LOADED:
                # may want to attach when all are ready
                var target_node = loading_requests[scene_path]
                _instantiate_and_attach(scene_path, target_node)
                completed_paths.append(scene_path)
                print("loaded ", scene_path)
            ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
                printerr("Failed to load scene: ", scene_path)
                completed_paths.append(scene_path)
    
    for path in completed_paths:
        loading_requests.erase(path)


func _instantiate_and_attach(scene_path: String, target_node: Node) -> void:
    var packed_scene: PackedScene = ResourceLoader.load_threaded_get(scene_path)
    if packed_scene and is_instance_valid(target_node):
        var instance = packed_scene.instantiate()
        target_node.add_child(instance)
        print("added child ", instance, " to ", target_node)
