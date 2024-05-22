extends Node

var server : ENetMultiplayerPeer

var gateway_api = MultiplayerAPI.create_default_interface()

var cert : X509Certificate = load("res://certs/X509.crt")
var key : CryptoKey = load("res://certs/X509.key")

var port : int = 1910
var max_players : int = 5

func _ready():
	server = ENetMultiplayerPeer.new()
	server.create_server(port, max_players)
	get_tree().set_multiplayer(gateway_api, self.get_path())
	server.host.dtls_server_setup(TLSOptions.server(key, cert))
	multiplayer.multiplayer_peer = server
	print("Gateway started")
	
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

func _on_player_connected(player_id:int):
	print("Player " + str(player_id) + " connected")

func _on_player_disconnected(player_id:int):
	print("Player " + str(player_id) + " disconnected")


@rpc("any_peer", "reliable")
func login_request(email:String, password:String) -> void:
	print("Login request received")
	var player_id : int = multiplayer.get_remote_sender_id()
	Authenticate.authenticate_player(email, password, player_id)


@rpc("any_peer", "reliable")
func create_account_request(email:String, password:String) -> void:
	print("Create account request received")
	var player_id : int = multiplayer.get_remote_sender_id()
	var valid_request = true
	var regex : RegEx = RegEx.new()
	regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	if not regex.search(email):
		valid_request = false
	elif password.length() < 8:
		valid_request = false
	
	if not valid_request:
		print("Petición no válida")
		return_create_account_request(valid_request, player_id, 1)
	else:
		print("Petición aparentemente válida")
		Authenticate.create_account(email.to_lower(), password, player_id)


@rpc("any_peer", "reliable")
func return_create_account_request(result:bool, player_id:int, message:int) -> void:
	rpc_id(player_id, "return_create_account_request", result, message)


@rpc("any_peer", "reliable", "call_local")
func return_login_request(result:bool, player_id:int, token:String) -> void:
	print("Envio del resultado")
	var status = rpc_id(player_id, "return_login_request", result, player_id, token)
	if status == OK:
		print("Enviado exitosamente")
	else:
		print("Fallo al enviarlo")

@rpc("any_peer","reliable")
func disconnect_player(player_id:int) -> void:
	print("Player " + str(player_id) + " desconectado exitosamente")
	server.disconnect_peer(player_id)
