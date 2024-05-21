class_name Pickup extends Resource

@export var name : String
@export var scene : PackedScene
@export var icon : Texture2D
@export var stack_size : int
@export var description : String
@export_enum("tool", "material", "other") var type : String
@export var damage:int = 0

func is_tool():
	return type == "tool"
