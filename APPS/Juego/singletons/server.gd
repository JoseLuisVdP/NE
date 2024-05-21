extends Node

var client

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
func test_connection():
	test_connection.rpc_id(1)
	print("Cliente OK")

@rpc("any_peer", "reliable")
func save_game(json:Dictionary):
	save_game.rpc_id(1, "prueba", json)

@rpc("any_peer", "reliable")
func get_data():
	rpc_id(1, "get_data")

@rpc("any_peer", "reliable")
func _on_data_retrieved(_data:Dictionary):
	var game : GAME = get_node("/root/Game")
	game.data = _data
	game.data_retrieved.emit()
