extends Node

var server : ENetMultiplayerPeer

var multiplayer_api = MultiplayerAPI.create_default_interface()
var port = 1912
var max_players = 5

var gameserverlist = {}

func _ready() -> void:
	start_server()

func start_server():	
	server = ENetMultiplayerPeer.new()
	server.create_server(port, max_players)
	get_tree().set_multiplayer(multiplayer_api, self.get_path())
	multiplayer.multiplayer_peer = server
	print("GameServerHub started")
	
	multiplayer.peer_connected.connect(_on_game_server_connected)
	multiplayer.peer_disconnected.connect(_on_game_server_disconnected)

func _on_game_server_connected(id):
	print("Game server " + str(id) + " connected")
	# Aquí se establece el nombre del servidor (balanceador de carga)
	gameserverlist["GameServer1"] = id

func _on_game_server_disconnected(id):
	print("Game server " + str(id) + " disconnected")

func distribute_login_token(token:String, game_server:String) -> void:
	var gameserver_peer_id : int = gameserverlist[game_server]
	rpc_id(gameserver_peer_id, "receive_login_token", token)

@rpc("any_peer", "reliable")
func receive_login_token(token:String) -> void:
	pass
