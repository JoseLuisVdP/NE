class_name NPCScene extends Node3D

@export var npc : NPC

func _ready() -> void:
	add_child(npc.scene.instantiate())
