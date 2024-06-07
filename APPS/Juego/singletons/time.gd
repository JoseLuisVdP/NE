class_name TIME extends Node

var time : int


var timer : Timer
const day : int = 86400
const SECOND_SCALE : int = 100
var day_time : int


var sun : DirectionalLight3D
var sun_energy : float
var moon : DirectionalLight3D
var moon_energy : float
var rotation : Vector3 = Vector3.ZERO


func iniciar(cur_time:int, _sun, _moon) -> void:
	time = cur_time
	sun = _sun
	moon = _moon
	sun_energy = sun.light_energy
	moon_energy = moon.light_energy
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 1
	timer.timeout.connect(second)
	add_child(timer)
	timer.timeout.emit()
	sun.rotation.x = rotation.x


func second():
	for i in range(SECOND_SCALE):
		time += 1
		update()
	timer.start()


func update():
	day_time = time % day
	update_astrals()
	update_lights()
	if day_time == 8640 or day_time == 77760:
		for i in get_tree().get_nodes_in_group("sounds_at_0"):
			i.play()


func update_lights():
	match day_time:
		4320:
			turn_lights(false)
		38880:
			turn_lights(true)
		43200:
			moon.light_energy = moon_energy
		46520:
			sun.light_energy = 0
		86390:
			sun.light_energy = sun_energy
			moon.light_energy = 0


func turn_lights(b:bool):
	for i in get_tree().get_nodes_in_group("citylights"):
		i.get_node("OmniLight3D").visible = b


func update_astrals():
	rotation = Vector3(day_time * TAU / day, 0, 0) * -1


func _physics_process(delta: float) -> void:
	if sun != null:
		sun.rotation.x = lerp_angle(sun.rotation.x, rotation.x, delta)
		moon.rotation = Vector3(sun.rotation.x + PI, 0, 0)


func is_between(t0:int, t1:int):
	var begin : int
	var end : int
	
	if t0 < t1:
		begin = t0
		end = t1
	else:
		begin = t1
		end = t0
	
	return begin < day_time and day_time < end
