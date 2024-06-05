extends Node3D

@onready var models: Node3D = $Models

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	models.get_children().all(func (i): i.hide())
	models.get_child(randi_range(0,3)).show()

