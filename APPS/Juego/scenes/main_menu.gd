extends Control

@export var loading_scene : PackedScene
@export var game_scenes_rg : ResourceGroup
@export var sounds_rg : ResourceGroup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scenes.loading_screen = loading_scene
	game_scenes_rg.load_all_into(Scenes.scenes)
	Scenes.load_dict()
	sounds_rg.load_all_into(SoundManager.sounds_array)
	SoundManager.load_sounds()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	Scenes.load_scene("login")


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_button_pressed() -> void:
	pass
