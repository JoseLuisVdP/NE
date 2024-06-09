extends MarginContainer


@onready var pause_menu: MarginContainer = $"../PauseMenu"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_menu.show()
		hide()
