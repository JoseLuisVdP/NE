extends Node

var client : ENetMultiplayerPeer

var gateway_api = MultiplayerAPI.create_default_interface()

var ip = "127.0.0.1"
var port = 1910

var email : String
var password : String

signal login_success

func connect_to_server(_email:String, _password:String) -> void:
	email = _email
	password = _password
	
	client = ENetMultiplayerPeer.new()
	client.create_client(ip, port)
	get_tree().set_multiplayer(gateway_api, self.get_path())
	multiplayer.multiplayer_peer = client
	
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_connection_failed():
	print("Ha fallado la conexión al servidor")

func _on_connected_to_server():
	print("Conectado al servidor correctamente. Haciendo login")
	request_login()

func request_login():
	print("Requesting login")
	rpc_id(1, "login_request", email, password)
	email = ""
	password = ""

@rpc("any_peer", "reliable")
func login_request(email, password):
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
	
	# No estoy seguro de que esta llamada vaya aquí, testea
	rpc_id(1, "disconnect_player", player_id)
	
	multiplayer.connection_failed.disconnect(_on_connection_failed)
	multiplayer.connected_to_server.disconnect(_on_connected_to_server)

@rpc("any_peer","reliable")
func disconnect_player(player_id):
	pass
