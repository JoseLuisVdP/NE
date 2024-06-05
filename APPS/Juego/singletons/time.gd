class_name TIME extends Node

var time : int

var timer : Timer
const day : int = 600
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
	timer.wait_time = 0.1
	timer.timeout.connect(second)
	add_child(timer)
	timer.timeout.emit()
	sun.rotation.x = rotation.x


func second():
	time += 1
	timer.start()
	update()


func update():
	update_astrals()
	update_lights()
	if day_time == 10:
		for i in get_tree().get_nodes_in_group("sounds_at_0"):
			i.play()


func update_lights():
	match day_time:
		30:
			turn_lights(false)
		270:
			turn_lights(true)
		330:
			sun.light_energy = 0
		5905:
			sun.light_energy = sun_energy / 10
		596:
			sun.light_energy = sun_energy / 5
		598:
			sun.light_energy = sun_energy / 2
		599:
			sun.light_energy = sun_energy


func turn_lights(b:bool):
	for i in get_tree().get_nodes_in_group("citylights"):
		i.get_node("OmniLight3D").visible = b


func update_astrals():
	day_time = time % day
	rotation = Vector3(day_time * TAU / day, 0, 0) * -1


func _physics_process(delta: float) -> void:
	if sun != null:
		sun.rotation.x = lerp_angle(sun.rotation.x, rotation.x, delta)
		moon.rotation = Vector3(sun.rotation.x + PI, 0, 0)
