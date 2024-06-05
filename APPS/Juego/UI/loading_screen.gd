class_name LoadingScreen extends CanvasLayer

var scene_name : String
var progress : Array
var preload_progress : float
var queue_process : bool = false
var is_process_running : bool = false
var process_count : int = 0

var scene

@onready var radial_progress: RadialProgress = %RadialProgress
@onready var label: Label = %Label
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

@export var wait_to_finish : bool = false

func _ready():
	scene_name = Scenes.next_scene.resource_path
	ResourceLoader.load_threaded_request(scene_name)
	Scenes.loading_screen = self
	animated_sprite_2d.frame = 0
	animated_sprite_2d.play()
	

func _physics_process(delta: float) -> void:
	ResourceLoader.load_threaded_get_status(scene_name, progress)
	
	if !is_process_running:
		radial_progress.progress = progress[0] * radial_progress.max_value
	else:
		radial_progress.progress = lerp(radial_progress.progress, preload_progress * radial_progress.max_value, 0.1)
	
	if progress[0] == 1 and !is_process_running:
		var packed_scene : PackedScene = ResourceLoader.load_threaded_get(scene_name)
		scene = packed_scene.instantiate()

		get_tree().root.add_child(scene)
		
		SoundManager.install_sounds(get_tree().root)
		queue_process = true
		
	if queue_process:
		is_process_running = true
		queue_process = false
		if not wait_to_finish:
			hide()
		else:
			scene.hide()
		if scene.has_method("pre_load"):
			scene.pre_load()
		else:
			_on_loaded()
	
	if scene.has_method("pre_load") and scene.loaded:
		_on_loaded()


func _on_loaded():
	scene.show()
	queue_free()
