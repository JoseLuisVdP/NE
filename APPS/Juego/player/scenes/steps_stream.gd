extends AudioStreamPlayer


@export var step_sounds : Array[AudioStreamWAV] = []


@onready var state_chart: PlayerStateMachine = %StateChart
@onready var timer: Timer = $Timer

var cooldown : float


func _ready():
	cooldown = timer.wait_time
	timer.start()
	randomize()


func play_step_sound():
	var random_index = randi() % step_sounds.size()
	stream = step_sounds[random_index]
	play()


func _on_timer_timeout() -> void:
	play_step_sound()
	if state_chart.is_walking():
		timer.start()
	elif state_chart.is_player_running():
		timer.start(cooldown/2)
	else:
		timer.stop()
	
