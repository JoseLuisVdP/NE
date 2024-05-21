class_name SCENES extends Node

var loading_screen : PackedScene
var scenes : Array[PackedScene]
var scenes_dict : Dictionary
var next_scene : PackedScene

func load_scene(scene_name:String) -> void:
	get_tree().change_scene_to_packed(loading_screen)
	next_scene = scenes_dict[scene_name]

func load_dict():
	scenes_dict = {}
	for i in scenes:
		var name : String = i.resource_path.get_file().get_basename()
		scenes_dict[name] = i
