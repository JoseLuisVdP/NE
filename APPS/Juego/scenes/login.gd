extends Control

@onready var email_input: LineEdit = %EmailInput
@onready var password_input: LineEdit = %PasswordInput
@onready var login_btn: Button = %LoginBtn
@onready var register_btn: Button = %RegisterBtn
@onready var login_timer: Timer = %LoginTimer

func _ready():
	Gateway.login_success.connect(_on_login_success)

func _on_login_btn_pressed() -> void:
	if email_input.text == "" or password_input.text == "":
		print("LOGIN: Rellena ambos campos para continuar")
		return
	else:
		print("LOGIN: intentar login")
		login_btn.disabled = true
		print("Attempting to login")
		Gateway.connect_to_server(email_input.text, password_input.text)
		login_timer.start()

func _on_timer_timeout() -> void:
	login_timer.stop()
	login_btn.disabled = false

func _on_login_success():
	login_timer.stop()
	remove_child(login_timer)
	Scenes.load_scene("game")
	queue_free()
