class_name NPCScene extends Node3D


@export var npc : NPC
var npc_scene : Node3D
var path : Path3D
var path_follow : PathFollow3D
var player : Node3D

var is_talking : bool = false
@onready var state_chart: StateChart = $StateChart


func _ready() -> void:
	npc_scene = npc.scene.instantiate()
	add_child(npc_scene)
	path = $"../../NPCPaths/test"
	path_follow = $"../../NPCPaths/test/test"
	
	if path_follow != null:
		npc_scene.global_position = path_follow.global_position
		npc_scene.rotation = path_follow.rotation


func talk(_player:Node3D):
	player = _player
	is_talking = true
	ConversationManager.cur_talker = self
	state_chart.send_event("stop")


func stop_talking():
	is_talking = false
	state_chart.send_event("walk")


"""
		path_follow.progress += 0.02
		npc_scene.global_position = path_follow.global_position
		npc_scene.rotation = path_follow.rotation
"""


func _on_idle_state_physics_processing(delta: float) -> void:
	if npc_scene.has_method("play_animation"):
		npc_scene.play_animation("Idle")
	npc_scene.rotation = player.rotation.rotated(Vector3.UP, PI)


func _on_walk_state_physics_processing(delta: float) -> void:
	if path_follow != null:
		path_follow.progress += 0.02
		npc_scene.global_position = path_follow.global_position
		npc_scene.rotation = path_follow.rotation
		
		if npc_scene.has_method("play_animation"):
			npc_scene.play_animation("Walk")
