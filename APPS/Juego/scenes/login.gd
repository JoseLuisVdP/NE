extends Control

@onready var email_input: LineEdit = %EmailInput
@onready var password_input: LineEdit = %PasswordInput
@onready var login_btn: Button = %LoginBtn
@onready var register_btn: Button = %RegisterBtn

func _on_login_btn_pressed() -> void:
	if email_input.text == "" or password_input.text == "":
		print("LOGIN: Rellena ambos campos para continuar")
		return
	else:
		print("LOGIN: intentar login")
		login_btn.disabled = true
		print("Attempting to login")
		Gateway.connect_to_server(email_input.text, password_input.text)
