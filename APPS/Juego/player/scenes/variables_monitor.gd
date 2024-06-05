class_name Monitor extends Label

@export var toBeMonitored : Dictionary
@onready var _player: Player = $".."

func set_monitor_values():
	toBeMonitored["velocidad"] = _player.linear_velocity
	toBeMonitored["camara"] = str(_player.camera.get_rotation_degrees_x()) + " - " + str(_player.camera.get_rotation_degrees_y())
	toBeMonitored["player_rotation"] = _player.mesh.rotation_degrees
	toBeMonitored["Pickable items"] = _player.pickable_objects
	toBeMonitored["NPCs"] = _player.npcs
	toBeMonitored["Shoul Move"] = _player._should_move
	toBeMonitored["Angle"] = str(_player.floor_angle.get_collision_normal().angle_to(Vector3.UP)) + "(" + str(_player.ground_dot_product) + ")"
	toBeMonitored["CollidingBodies (floor)"] = _player.floor_collider.any(func (i): return i.is_colliding())
	toBeMonitored["Raycast (floor)"] = _player.floor_angle.is_colliding()
	toBeMonitored["Time"] = GlobalTime.time
	toBeMonitored["Day Time"] = GlobalTime.day_time
	
	text = ""
	
	for i in toBeMonitored:
		text += i + ": " + str(toBeMonitored[i])
		text += "\n"
