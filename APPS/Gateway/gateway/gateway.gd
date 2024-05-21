extends Node

var server : ENetMultiplayerPeer

var gateway_api = MultiplayerAPI.create_default_interface()

var port = 1910
var max_players = 5

func _ready():
	server = ENetMultiplayerPeer.new()
	server.create_server(port, max_players)
	get_tree().set_multiplayer(gateway_api, self.get_path())
	multiplayer.multiplayer_peer = server
	print("Gateway started")
	
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

func _on_player_connected(player_id):
	print("Player " + str(player_id) + " connected")

func _on_player_disconnected(player_id):
	print("Player " + str(player_id) + " disconnected")


@rpc("any_peer", "reliable")
func login_request(email:String, password:String):
	print("Login request received")
	var player_id : int = multiplayer.get_remote_sender_id()
	Authenticate.authenticate_player(email, password, player_id)

@rpc("any_peer", "reliable", "call_local")
func return_login_request(result:bool, player_id, token) -> void:
	print("Envio del resultado")
	var status = rpc_id(player_id, "return_login_request", result, player_id, token)
	if status == OK:
		print("Enviado exitosamente")
	else:
		print("Fallo al enviarlo")

@rpc("any_peer","reliable")
func disconnect_player(player_id):
	print("Player " + str(player_id) + " desconectado exitosamente")
	server.disconnect_peer(player_id)
