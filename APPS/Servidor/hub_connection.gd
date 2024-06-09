class_name HUB_CONNECTION extends Node

var client : ENetMultiplayerPeer

var multiplayer_api = MultiplayerAPI.create_default_interface()
var ip : String = "127.0.0.1"
var port : int = 1912

var game_server : Server

func _ready() -> void:
	game_server = get_node_or_null("/root/Server")
	start_server()

func start_server():
	client = ENetMultiplayerPeer.new()
	client.create_client(ip, port)
	get_tree().set_multiplayer(multiplayer_api, self.get_path())
	multiplayer.multiplayer_peer = client
	print("GameServer started")
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

func _on_connected_to_server():
	print("Conectado al hub correctamente")

func _on_connection_failed():
	print("No se ha podido conectar al Hub")

@rpc("any_peer", "reliable")
func receive_login_token(token:String) -> void:
	print("Token recibido, añadiendo...")
	game_server.expected_tokens.append(token)


@rpc("any_peer", "reliable")
func save_game_data(data:Dictionary, player_id:int, server_id:int = 1) -> void:
	print("Guardando partida de " + str(player_id))
	server_id = multiplayer.get_unique_id()
	rpc_id(1,"save_game_data", data, player_id, server_id)


@rpc("any_peer", "reliable")
func game_data_saved(result:bool, player_id: int, server_id:int = 1) -> void:
	game_server.data_saved(result, player_id)


@rpc("any_peer", "reliable")
func get_player_savefile(savefile:String, player_id:int, server_id:int = 1) -> void:
	print("Obteniendo save file")
	server_id = multiplayer.get_unique_id()
	rpc_id(1, "get_player_savefile", savefile, player_id, server_id)

@rpc("any_peer", "reliable")
func return_player_savefile(savefile_data:Dictionary, player_id:int, server_id:int, exito:bool) -> void:
	print("Recibido savefile de la base de datos")
	game_server.return_savefile(savefile_data, player_id, exito)

