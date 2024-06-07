@icon("./assets/quest_resource.svg")
extends Resource
class_name Quest

@export var id: int
@export var quest_name: String
@export_multiline var quest_description: String
@export_multiline var quest_objective: String
@export var quest_xp : int = 0
@export var quest_money : int = 0

var objective_completed: bool = false:
	set(value):
		objective_completed = value
	get:
		return objective_completed

func update() -> void:
	objective_completed = true

func start() -> void:
	pass

func complete() -> void:
	pass
