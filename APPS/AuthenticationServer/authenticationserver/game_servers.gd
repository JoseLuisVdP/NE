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


@rpc("any_peer", "reliable")
func save_game_data(data:Dictionary, player_id:int, server_id:int = 1) -> void:
	get_node("/root/Authenticate/SaveAndLoad").save_game(data, player_id, server_id)


@rpc("any_peer", "reliable")
func game_data_saved(result:bool, player_id : int, server_id:int = 1) -> void:
	rpc_id(server_id, "game_data_saved", result, player_id)


@rpc("any_peer", "reliable")
func get_player_savefile(savefile:String, player_id:int, server_id:int) -> void:
	print("Recibida petición de savefile")
	get_node("/root/Authenticate/SaveAndLoad").load_game(savefile, player_id, server_id)

@rpc("any_peer", "reliable")
func return_player_savefile(savefile_data:Dictionary, player_id:int, server_id:int, exito:bool) -> void:
	print("Devolviendo savefile a " + str(server_id))
	rpc_id(server_id, "return_player_savefile", savefile_data, player_id, server_id, exito)
