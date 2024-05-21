class_name Monitor extends Label

@export var toBeMonitored : Dictionary
@onready var _player: Player = $".."

func set_monitor_values():
	toBeMonitored["velocidad-x"] = _player.linear_velocity.x
	toBeMonitored["velocidad-y"] = _player.linear_velocity.y
	toBeMonitored["velocidad-z"] = _player.linear_velocity.z
	toBeMonitored["camara-x"] = _player.camera.get_rotation_degrees_x()
	toBeMonitored["camara-y"] = _player.camera.get_rotation_degrees_y()
	toBeMonitored["playermesh-x"] = _player.mesh.rotation_degrees.x
	toBeMonitored["playermesh-y"] = _player.mesh.rotation_degrees.y
	toBeMonitored["Pickable items"] = _player.pickable_objects
	toBeMonitored["NPCs"] = _player.npcs
	toBeMonitored["Shoul Move"] = _player._should_move
	toBeMonitored["Angle"] = _player.floor_angle.get_collision_normal().angle_to(Vector3.UP)
	toBeMonitored["DotProd"] = _player.ground_dot_product
	toBeMonitored["CollidingBodies (floor)"] = _player.floor_collider.any(func (i): return i.is_colliding())
	toBeMonitored["Raycast (floor)"] = _player.floor_angle.is_colliding()
	
	text = ""
	
	for i in toBeMonitored:
		text += i + ": " + str(toBeMonitored[i])
		text += "\n"
