extends Node

@onready var repository: Repository = %Repository

var server

var port = 1911
var max_servers = 10

func _ready():
	multiplayer.peer_connected.connect(_on_gateway_connected)
	multiplayer.peer_disconnected.connect(_on_gateway_disconnected)
	
	server = ENetMultiplayerPeer.new()
	server.create_server(port, max_servers)
	multiplayer.multiplayer_peer = server
	
	print("AuthenticationServer started")

func _on_gateway_connected(gateway_id):
	print("Gateway " + str(gateway_id) + " connected")

func _on_gateway_disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " disconnected")


@rpc("any_peer", "reliable")
func authenticate_player(email:String, password:String, player_id:int):
	print("Authentication request received")
	var gateway_id = multiplayer.get_remote_sender_id()
	var result : bool = false
	if not repository.GAME_REPOSITORY.player_email_exists(email):
		print("No se encuentra el email")
	elif not repository.GAME_REPOSITORY.player_password_is_correct(email, password):
		print("Contraseña incorrecta")
	else:
		print("Autenticación exitosa")
		result = true
	print("Autenticación enviada a gateway")
	rpc_id(gateway_id, "authentication_results", result, player_id)

@rpc("any_peer", "reliable")
func authentication_results(result, player_id):
	pass
