
class_name PickupScene extends Node3D

@export var item:Pickup
@onready var despawn: Timer = $Despawn


func _ready():
	if item != null:
		var instance = item.scene.instantiate()
		add_child(instance)
	else:
		print("null item" + str(get_instance_id()))


func _on_despawn_timeout() -> void:
	queue_free()
