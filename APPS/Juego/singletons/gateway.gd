class_name GATEWAY extends Node

var client : ENetMultiplayerPeer

var gateway_api = MultiplayerAPI.create_default_interface()

var ip = "127.0.0.1"
var port = 1910

var cert : X509Certificate = load("res://certs/X509.crt")

var email : String
var password : String
var new_account : bool

signal login_success

func connect_to_server(_email:String, _password:String, _new_account:bool = false) -> void:
	email = _email
	password = _password
	new_account = _new_account
	
	client = ENetMultiplayerPeer.new()
	client.create_client(ip, port)
	client.host.dtls_client_setup("hostname", TLSOptions.client_unsafe(cert))
	get_tree().set_multiplayer(gateway_api, self.get_path())
	multiplayer.multiplayer_peer = client
	
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_connection_failed():
	print("Ha fallado la conexión al servidor")
	printerr("POPUP DE QUE EL SERVER ESTA CAIDO")
	var login : LoginScreen = get_node("/root/Login")
	login.login_btn.disabled = false
	login.register_btn.disabled = false
	login.confirm_btn.disabled = false
	login.back_btn.disabled = false
	

func _on_connected_to_server():
	print("Conectado al servidor correctamente. Haciendo login")
	if new_account:
		request_create_account()
	else:
		request_login()

func request_login():
	print("Requesting login")
	rpc_id(1, "login_request", email, password.sha256_text())
	email = ""
	password = ""

func request_create_account():
	print("Requesting register")
	rpc_id(1, "create_account_request", email, password.sha256_text())
	email = ""
	password = ""


@rpc("any_peer", "reliable")
func return_create_account_request(result:bool, message:int) -> void:
	print("Create account result received")
	if result:
		print("La cuenta se ha creado correctamente, haz login")
		printerr("POPUP AL USUARIO PLZ")
		get_node("/root/Login")._on_back_btn_pressed()
	else:
		match message:
			1:
				print("No se pudo crear la cuenta, inténtalo de nuevo")
			2:
				print("El correo especificado ya tiene una cuenta, inténtalo con otro correo o inicia sesión")
			3:
				print("Todo ha ido bien, no deberías estar viendo este mensaje")
			4:
				print("Ha ocurrido un error en la base de datos, inténtalo de nuevo")
		
		get_node("/root/Login").confirm_btn.disabled = false
		get_node("/root/Login").back_btn.disabled = false
	
	multiplayer.connection_failed.disconnect(_on_connection_failed)
	multiplayer.connected_to_server.disconnect(_on_connected_to_server)
	rpc_id(1, "disconnect_player", multiplayer.get_unique_id())

@rpc("any_peer", "reliable")
func login_request(email, password):
	pass

@rpc("any_peer", "reliable")
func create_account_request(email, password):
	pass

@rpc("any_peer", "reliable", "call_local")
func return_login_request(result:bool, player_id, token):
	print("Results received")
	if result:
		print("Login ok")
		printerr("POPUP AL USUARIO PLZ")
		Server.token = token
		Server.connect_to_server()
	else:
		print("Correo o contraseña incorrecto")
		get_node("/root/Login").login_btn.disabled = false
		get_node("/root/Login").register_btn.disabled = false
	
	rpc_id(1, "disconnect_player", player_id)
	
	multiplayer.connection_failed.disconnect(_on_connection_failed)
	multiplayer.connected_to_server.disconnect(_on_connected_to_server)

@rpc("any_peer","reliable")
func disconnect_player(player_id):
	pass
