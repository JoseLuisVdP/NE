class_name TIME extends Node

var time : int


var timer : Timer
const DAY : int = 86400
var SECOND_SCALE : int = 5
var day_time : int
var day_time_formated : int

var prev_day : int = 0
var cur_day : int = 1
var cur_month : int = 1
const month_length : int = 28

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
	timer.wait_time = 0.05
	timer.timeout.connect(second)
	add_child(timer)
	timer.timeout.emit()
	sun.rotation.x = rotation.x
	if day_time > 46520 and day_time < DAY:
		sun.light_energy = 0
	Server.get_clima(2023, cur_month, Server.clima_places)


func second():
	for i in range(SECOND_SCALE):
		time += 1
		update()
	timer.start()


func update():
	day_time = time % DAY
	day_time_formated = int(time + DAY/3) % DAY
	update_astrals()
	update_lights()
	if day_time == 8640 or day_time == 40000:
		for i in get_tree().get_nodes_in_group("sounds_at_0"):
			i.play()
	elif day_time == 0 and time != 0:
		prev_day = cur_day
		cur_day = int(time / DAY) % month_length + 1
		if prev_day > cur_day:
			if cur_month > 12:
				cur_month = 1
			else:
				cur_month += 1
			Server.clima_data = {}
			Server.get_clima(2023, cur_month , Server.clima_places)

func update_lights():
	match day_time:
		0:
			SECOND_SCALE = 5
			sun.light_energy = sun_energy * 0.2
			moon.light_energy = moon_energy * 0.8
		100:
			sun.light_energy = sun_energy * 0.3
			moon.light_energy = moon_energy * 0.7
		200:
			sun.light_energy = sun_energy * 0.4
			moon.light_energy = moon_energy * 0.6
		300:
			sun.light_energy = sun_energy * 0.5
			moon.light_energy = moon_energy * 0.5
		400:
			sun.light_energy = sun_energy * 0.6
			moon.light_energy = moon_energy * 0.4
		500:
			sun.light_energy = sun_energy * 0.7
			moon.light_energy = moon_energy * 0.3
		600:
			sun.light_energy = sun_energy * 0.75
			moon.light_energy = moon_energy * 0.25
		900:
			sun.light_energy = sun_energy * 0.8
			moon.light_energy = 0
		1200:
			sun.light_energy = sun_energy * 0.9
		3000:
			sun.light_energy = sun_energy * 0.95
		4320:
			sun.light_energy = sun_energy
			turn_lights(false)
		25000:
			sun.light_energy = sun_energy * 0.95
		30000:
			sun.light_energy = sun_energy * 0.9
		36000:
			sun.light_energy = sun_energy * 0.8
		38880:
			turn_lights(true)
			sun.light_energy = sun_energy * 0.7
		39400:
			sun.light_energy = sun_energy * 0.6
		40000:
			sun.light_energy = sun_energy * 0.5
		41000:
			sun.light_energy = sun_energy * 0.4
		42000:
			sun.light_energy = sun_energy * 0.25
		43200:
			sun.light_energy = sun_energy * 0.2
			moon.light_energy = moon_energy
		44000:
			sun.light_energy = sun_energy * 0.1
		45000:
			sun.light_energy = sun_energy * 0.05
		46520:
			sun.light_energy = 0
		86390:
			sun.light_energy = sun_energy * 0.1
			moon.light_energy = moon_energy * 0.9


func turn_lights(b:bool):
	for i in get_tree().get_nodes_in_group("citylights"):
		var light = i.get_node_or_null("OmniLight3D")
		if light != null:
			light.visible = b



func update_astrals():
	rotation = Vector3(day_time * TAU / DAY, 0, 0) * -1


func _physics_process(delta: float) -> void:
	if sun != null:
		sun.rotation.x = lerp_angle(sun.rotation.x, rotation.x, delta)
		moon.rotation = Vector3(sun.rotation.x + PI, 0, 0)


func is_between(t0:int, t1:int):
	if t0 > t1:
		return t0 < day_time or day_time < t1
	else:
		return t0 < day_time and day_time < t1

func skip_night():
	SECOND_SCALE = 100
