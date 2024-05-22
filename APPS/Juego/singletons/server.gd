extends Node

var client

var token

var ip = "127.0.0.1"
var port = 1909

func _ready() -> void:
	pass

func connect_to_server():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
	client = ENetMultiplayerPeer.new()
	client.create_client(ip, port)
	multiplayer.multiplayer_peer = client

func _on_player_connected(player_id):
	print("Player " + str(player_id) + " connected to server")

func _on_player_disconnected(player_id):
	print("Player " + str(player_id) + " disconnected from server")

func _on_connection_failed():
	print("Falló la conexión al servidor")

@rpc("any_peer", "reliable")
func get_data():
	rpc_id(1, "get_data")

@rpc("any_peer", "reliable")
func _on_data_retrieved(_data:Dictionary):
	var game : GAME = get_node("/root/Game")
	game.data = _data
	game.data_retrieved.emit()

@rpc("any_peer","reliable")
func fetch_token(player_id:int) -> void:
	rpc_id(1, "return_token", token)

@rpc("any_peer","reliable")
func return_token(token:String) -> void:
	pass

@rpc("any_peer", "reliable")
func return_token_verification_result(player_id:int, token_verification:bool) -> void:
	print("Resultado de la verificación del token:")
	var login : Control = get_node("/root/Login")
	if token_verification:
		print("Token verificado")
		login.queue_free()
		Scenes.load_scene("game")
	else:
		print("Login fallido (token malo)")
		login.login_btn.disabled = false
		login.register_btn.disabled = false
