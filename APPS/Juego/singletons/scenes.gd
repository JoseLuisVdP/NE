class_name SCENES extends Node

var loading_screen_scene : PackedScene
var loading_screen : LoadingScreen
var scenes : Array[PackedScene]
var scenes_dict : Dictionary
var next_scene : PackedScene


func load_scene(scene_name:String) -> void:
	get_tree().change_scene_to_packed(loading_screen_scene)
	next_scene = scenes_dict[scene_name]


func load_dict():
	scenes_dict = {}
	for i in scenes:
		var name : String = i.resource_path.get_file().get_basename()
		scenes_dict[name] = i


func update_loading_sreen_title(title:String):
	if not (loading_screen.is_queued_for_deletion() and loading_screen == null):
		loading_screen.label.text = title


func update_loading_sreen_progress(progress:float):
	if not (loading_screen.is_queued_for_deletion() and loading_screen == null):
		loading_screen.preload_progress = progress
