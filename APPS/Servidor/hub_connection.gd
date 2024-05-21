class_name HUB_CONNECTION extends Node

var client : ENetMultiplayerPeer

var multiplayer_api = MultiplayerAPI.create_default_interface()
var ip : String = "127.0.0.1"
var port : int = 1912

var game_server : Server

func _ready() -> void:
	game_server = get_node("/root/Server")
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
	game_server.expected_tokens.append(token)
