extends CharacterBody3D

var path_follow : PathFollow3D
var parent : EnemyScene
var is_dying : bool = false
var prev_pos : Vector3

@onready var state_chart: StateChart = $StateChart
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stopped_timer: Timer = $StoppedTimer

func _ready() -> void:
	if path_follow != null:
		path_follow.progress_ratio = randf()
		prev_pos = path_follow.position
		print("Progress: " + str(path_follow.progress))
	parent = get_parent()

func die():
	is_dying = true


func _on_stopped_state_entered() -> void:
	animation_player.speed_scale = 1


func _on_stopped_state_physics_processing(delta: float) -> void:
	animation_player.play("watch")


func _on_returning_to_path_state_entered() -> void:
	animation_player.speed_scale = 0.6

"""
func _on_returning_to_path_state_exited() -> void:
	pass # Replace with function body.
"""

func _on_returning_to_path_state_physics_processing(delta: float) -> void:
	animation_player.play("Walking Animation")
	#Move to prev_pos
	if position == prev_pos:
		state_chart.send_event("idle")


func _on_idle_state_entered() -> void:
	animation_player.speed_scale = 0.75
	stopped_timer.start(randf_range(2,8))


"""
func _on_idle_state_exited() -> void:
	pass # Replace with function body.
"""

func _on_idle_state_physics_processing(delta: float) -> void:
	if not is_dying:
		animation_player.play("Walking Animation")
		if path_follow != null:
			path_follow.progress += parent.instance_properties.velocity_points * 0.7
			parent.position = path_follow.position
			parent.rotation = path_follow.rotation
	#Check if player is in area
	if false:
		state_chart.send_event("chase")


func _on_chasing_state_entered() -> void:
	animation_player.speed_scale = 1
	stopped_timer.stop()

"""
func _on_chasing_state_exited() -> void:
	pass # Replace with function body.
"""

func _on_chasing_state_physics_processing(delta: float) -> void:
	#Follow the player through navegable mesh (tutorial)
	#Check if player is out of area
	if false:
		state_chart.send_event("stop")
	#Check if player is in attack area
	elif false:
		state_chart.send_event("atack")


func _on_attacking_state_entered() -> void:
	animation_player.speed_scale = 1


func _on_attacking_state_exited() -> void:
	pass
	#hit()
	# Debemos hacer un pequeño dash hacia delante


func _on_attacking_state_physics_processing(delta: float) -> void:
	animation_player.play("atack")


func _on_cooldown_state_entered() -> void:
	pass # Replace with function body.


func _on_cooldown_state_exited() -> void:
	pass


func _on_cooldown_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_stopped_timer_timeout() -> void:
	state_chart.send_event("stop")
	stopped_timer.start(randf_range(2,8))
