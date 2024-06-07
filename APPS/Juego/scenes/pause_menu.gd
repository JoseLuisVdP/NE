extends Control

@onready var opciones: MarginContainer = %Opciones
@onready var pause_menu: MarginContainer = $"."

func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and MyQuestManager.player.chatting_npc == null:
		toggle_pause()


func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_exit_options() -> void:
	opciones.hide()
	pause_menu.show()


func _on_options_pressed() -> void:
	opciones.show()
	pause_menu.hide()
