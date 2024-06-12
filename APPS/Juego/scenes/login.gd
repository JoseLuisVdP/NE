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
@onready var wrong_login: Window = %WrongLogin
@onready var wrong_register: Window = %WrongRegister
@onready var empty_login: Window = %EmptyLogin
@onready var mail_already_exists: Window = %MailAlreadyExists
@onready var generic_error: Window = %GenericError


@export var auto_save : PackedScene

var email : String

func _ready() -> void:
	register.hide()
	login.show()
	Server.auto_save_scene = auto_save
	Gateway.login_node = self

func _on_login_btn_pressed() -> void:
	if email_input.text == "" or password_input.text == "":
		empty_login.show()
		return
	else:
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
	confirm_btn.disabled = false
	back_btn.disabled = false


func _on_confirm_btn_pressed() -> void:
	var regex : RegEx = RegEx.new()
	regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	if not regex.search(new_email_input.text):
		wrong_register.show()
	elif new_password_input.text.length() < 8:
		wrong_register.show()
	elif new_password_input.text != repeat_new_password_input.text:
		wrong_register.show()
	else:
		confirm_btn.disabled = true
		back_btn.disabled = true
		Gateway.connect_to_server(new_email_input.text, new_password_input.text, true)
		email = new_email_input.text


func _on_test_login_pressed() -> void:
	email_input.text = "a@a.com"
	password_input.text = "aaaaaaaa"
	_on_login_btn_pressed()


func _on_wrong_login_close_requested() -> void:
	wrong_login.hide()


func _on_wrong_register_close_requested() -> void:
	wrong_register.hide()


func _on_empty_login_close_requested() -> void:
	empty_login.hide()


func _on_mail_already_exists_close_requested() -> void:
	mail_already_exists.hide()


func _on_generic_error_close_requested() -> void:
	generic_error.hide()
