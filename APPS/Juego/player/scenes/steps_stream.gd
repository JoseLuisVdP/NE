extends AudioStreamPlayer


@export var step_sounds : Array[AudioStreamWAV] = []
@export var cooldown : int = 1


@onready var state_chart: PlayerStateMachine = %StateChart
@onready var timer: Timer = $Timer


func _ready():
	timer.wait_time = cooldown
	timer.start()
	randomize()


func play_step_sound():
	var random_index = randi() % step_sounds.size()
	stream = step_sounds[random_index]
	play()


func _on_timer_timeout() -> void:
	if state_chart.is_walking():
		play_step_sound()
