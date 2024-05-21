extends Node

var client

var ip = "127.0.0.1"
var port = 1911

func _ready():
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	
	client = ENetMultiplayerPeer.new()
	client.create_client(ip,port)
	multiplayer.multiplayer_peer = client

func _on_connection_failed():
	print("Ha fallado la conexión al servidor")

func _on_connected_to_server():
	print("Conectado al servidor correctamente")

@rpc("any_peer","reliable")
func authenticate_player(email:String, password:String, player_id:int):
	print("Enviando authentication request a authentication server")
	rpc_id(1, "authenticate_player", email, password, player_id)

@rpc("any_peer","reliable")
func authentication_results(result:bool, player_id, token) -> void:
	print("Resultado de la autenticación recibido, enviando al jugador...")
	Gateway.return_login_request(result, player_id, token)
