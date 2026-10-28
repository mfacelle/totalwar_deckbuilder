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
var loading_screen_scene: PackedScene = preload("uid://ctmue1buij8b2")

## path to scene to be loaded, mapped to their target nodes
var loading_requests: Dictionary[String, Node] = {}
## active loading screen node, or null if not present
var load_screen: Node = null
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
    
     # if loading screen not present, set it up. Wait for it to be ready before loading first scene
    if not load_screen:
        load_screen = loading_screen_scene.instantiate()
        add_child(load_screen)
        progress_changed.connect(load_screen._on_progress_changed)
        load_finished.connect(load_screen._on_load_finished)
        
        await load_screen.loading_screen_ready
        
        var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
        if state == OK:
            set_process(true)
    else:
        # loading screen already present, just kick off scene load
        var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
        if state != OK:
            printerr("Failed to start loading scene: ", scene_path)


## handle loading requested scenes
func _process(_delta: float) -> void:
    if loading_requests.is_empty():
        set_process(false)
        return
    
    var completed_paths: Array[String] = []
    
    var overall_progress: float = 0
    
    for scene_path in loading_requests.keys():
        var progress: Array = []
        var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
        overall_progress += progress[0]
        
        match status:
            ResourceLoader.THREAD_LOAD_LOADED:
                # may want to attach when all are ready
                #var target_node = loading_requests[scene_path]
                #_instantiate_and_attach(scene_path, target_node)
                completed_paths.append(scene_path)
            ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
                printerr("Failed to load scene: ", scene_path)
                ## TODO probably not the best way to handle this, but keeps us from being stuck loading
                completed_paths.append(scene_path)
    
    # report overall loading progress
    progress_changed.emit(overall_progress / loading_requests.size())
    
    # if all loading tasks are done, instantiate scenes and attach to nodes
    if completed_paths.size() == loading_requests.size():
        print("instantiating scenes")
        for scene_path in loading_requests.keys():
            _instantiate_and_attach(scene_path, loading_requests[scene_path])
            loading_requests.erase(scene_path)
            load_finished.emit()


func _instantiate_and_attach(scene_path: String, target_node: Node) -> void:
    var packed_scene: PackedScene = ResourceLoader.load_threaded_get(scene_path)
    if packed_scene and is_instance_valid(target_node):
        var instance = packed_scene.instantiate()
        target_node.add_child(instance)
        print("added child ", instance, " to ", target_node)
