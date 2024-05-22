class_name LoginScreen extends Control
@onready var login: MarginContainer = %Login
@onready var email_input: LineEdit = %EmailInput
@onready var password_input: LineEdit = %PasswordInput
@onready var login_btn: Button = %LoginBtn
@onready var register_btn: Button = %RegisterBtn

@onready var register: MarginContainer = %Register
@onready var confirm_btn: Button = %ConfirmBtn
@onready var back_btn: Button = %BackBtn
@onready var new_email_input: LineEdit = %NewEmailInput
@onready var new_password_input: LineEdit = %NewPasswordInput
@onready var repeat_new_password_input: LineEdit = %RepeatNewPasswordInput

var email : String

func _ready() -> void:
	register.hide()
	login.show()

func _on_login_btn_pressed() -> void:
	if email_input.text == "" or password_input.text == "":
		print("LOGIN: Rellena ambos campos para continuar")
		return
	else:
		print("LOGIN: intentar login")
		login_btn.disabled = true
		register_btn.disabled = true
		print("Attempting to login")
		Gateway.connect_to_server(email_input.text, password_input.text)
		email = email_input.text


func _on_back_btn_pressed() -> void:
	login.show()
	register.hide()


func _on_register_btn_pressed() -> void:
	login.hide()
	register.show()


func _on_confirm_btn_pressed() -> void:
	var regex : RegEx = RegEx.new()
	regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	if not regex.search(new_email_input.text):
		print("Correo inválido")
	elif new_password_input.text.length() < 8:
		print("La contraseña debe tener al menos 8 caracteres")
	elif new_password_input.text != repeat_new_password_input.text:
		print("Las contraseñas no coinciden")
	else:
		confirm_btn.disabled = true
		back_btn.disabled = true
		Gateway.connect_to_server(new_email_input.text, new_password_input.text, true)
		email = new_email_input.text
