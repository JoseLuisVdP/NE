
class_name PickupScene extends Node3D

@export var item:Pickup

func _ready():
	if item != null:
		var instance = item.scene.instantiate()
		add_child(instance)
	else:
		print("null item" + str(get_instance_id()))
