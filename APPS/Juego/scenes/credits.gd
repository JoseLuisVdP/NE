extends CanvasLayer

@onready var panel: Control = $Panel
@onready var timer: Timer = $Opacity
@onready var end: Timer = $End


func _ready() -> void:
	timer.start()
	timer.timeout.connect(_on_timer_timeout)
	panel.modulate.a = 0


func _on_timer_timeout():
	panel.modulate.a += 0.01
	if panel.modulate.a >= 0.99:
		timer.stop()
		timer.queue_free()
		end.start()
		end.timeout.connect(func (i): get_tree().quit())


func _on_button_pressed() -> void:
	get_tree().quit()
