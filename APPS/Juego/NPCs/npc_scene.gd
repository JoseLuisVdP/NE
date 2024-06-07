class_name NPCScene extends Node3D


@export var npc : NPC
var npc_scene : Node3D
var path : Path3D
var path_follow : PathFollow3D
var player : Node3D

var state_duplicate : int = 0


var is_talking : bool = false
@onready var state_chart: StateChart = $StateChart


@onready var npc_paths: Node3D = %NPCPaths


@onready var available: AnimatedSprite3D = %available
@onready var active: AnimatedSprite3D = %active
@onready var icons: Node3D = %Icons


func _ready() -> void:
	npc_scene = npc.scene.instantiate()
	add_child(npc_scene)
	path = npc_paths.get_child(get_index())
	path_follow = path.get_child(0)


func talk(_player_mesh:Node3D):
	player = _player_mesh
	is_talking = true
	ConversationManager.cur_talker = self
	state_chart.send_event("stop")


func stop_talking():
	is_talking = false
	state_chart.send_event("walk")


func accept_mission():
	QuestSystem.start_quest(npc.quest)
	state_chart.send_event("activate")
	state_duplicate = 1
	QuestSystem.available.remove_quest(npc.quest)


func complete_mission():
	npc.quest.objective_completed = true
	QuestSystem.complete_quest(npc.quest)
	state_chart.send_event("complete")
	state_duplicate = 2


"""
		path_follow.progress += 0.02
		npc_scene.global_position = path_follow.global_position
		npc_scene.rotation = path_follow.rotation
"""


func _on_idle_state_physics_processing(delta: float) -> void:
	if npc_scene.has_method("play_animation"):
		npc_scene.play_animation("Idle")
	npc_scene.animated_human.look_at(player.global_transform.origin, Vector3.UP)
	npc_scene.rotation = Vector3(npc_scene.rotation.x, lerp_angle(npc_scene.rotation.y, player.rotation.y + PI, 0.3), npc_scene.rotation.z)


func _on_walk_state_physics_processing(delta: float) -> void:
	if path_follow != null:
		path_follow.progress += 0.02
		npc_scene.global_position = path_follow.global_position
		npc_scene.animated_human.rotation = Vector3.ZERO
		npc_scene.rotation = Vector3(npc_scene.rotation.x, lerp_angle(npc_scene.rotation.y, path_follow.rotation.y, 0.3), npc_scene.rotation.z)
		
		if npc_scene.has_method("play_animation"):
			npc_scene.play_animation("Walk")
	icons.position = npc_scene.position


func _on_available_state_entered() -> void:
	available.call_deferred("show")
	available.call_deferred("play")


func _on_active_state_entered() -> void:
	available.call_deferred("stop")
	available.call_deferred("hide")
	active.call_deferred("show")
	active.call_deferred("play")


func _on_completed_state_entered() -> void:
	available.call_deferred("hide")
	active.call_deferred("hide")


func _on_available_state_physics_processing(delta: float) -> void:
	available.play()
	if QuestSystem.is_quest_active(npc.quest) or QuestSystem.is_quest_completed(npc.quest):
		state_chart.send_event("activate")


func _on_active_state_physics_processing(delta: float) -> void:
	if QuestSystem.is_quest_completed(npc.quest):
		state_chart.send_event("complete")


func _on_completed_state_physics_processing(delta: float) -> void:
	available.call_deferred("hide")
	active.call_deferred("hide")
