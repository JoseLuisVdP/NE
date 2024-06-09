extends Control

@export var loading_scene : PackedScene
@export var game_scenes_rg : ResourceGroup
@export var sounds_rg : ResourceGroup

@onready var main: MarginContainer = %Main
@onready var tutorial: MarginContainer = %Tutorial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scenes.loading_screen_scene = loading_scene
	game_scenes_rg.load_all_into(Scenes.scenes)
	Scenes.load_dict()
	sounds_rg.load_all_into(SoundManager.sounds_array)
	SoundManager.load_sounds()


func _on_play_pressed() -> void:
	Scenes.load_scene("login")


func _on_tutorial_pressed() -> void:
	tutorial.visible = not tutorial.visible


func _on_quit_pressed() -> void:
	get_tree().quit()
