class_name LoadingScreen extends Control

var scene_name : String
var progress : Array
var is_process_running : bool = false
var process_count : int = 0

@onready var radial_progress: RadialProgress = %RadialProgress
@export var wait_to_finish : bool = false

func _ready():
	scene_name = Scenes.next_scene.resource_path
	ResourceLoader.load_threaded_request(scene_name)

func _physics_process(delta: float) -> void:
	$MarginContainer/Label.text += "a"
	ResourceLoader.load_threaded_get_status(scene_name, progress)
	radial_progress.progress = progress[0] * radial_progress.max_value
	
	if progress[0] == 1 and !is_process_running:
		var packed_scene : PackedScene = ResourceLoader.load_threaded_get(scene_name)
		var scene = packed_scene.instantiate()

		get_tree().root.add_child(scene)
		
		SoundManager.install_sounds(get_tree().root)
		
		if not wait_to_finish:
			hide()
		if scene.has_method("pre_load") and scene.has_signal("loaded"):
			scene.loaded.connect(_on_loaded)
			scene.pre_load()
		else:
			_on_loaded()


func _on_loaded():
	get_parent().remove_child(self)
	queue_free()
