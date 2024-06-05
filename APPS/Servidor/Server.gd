class_name Server extends Node
## Main class for server functionality

@onready var player_verification: Node = %PlayerVerification

var server

var port = 1909
var max_players = 50

## Timers
@onready var timers : Timers = %Timers
@onready var repositories: Repository = %Repositories

@export var default_img : CompressedTexture2D
@onready var token_expiration: Timer = %TokenExpiration

var expected_tokens : Array[String] = []
const TOKEN_EXPIRATION_TIME : int = 30

## Starts all timers
func _ready():
	timers.start_all()
	init_api_scrapping()
	
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	
	server = ENetMultiplayerPeer.new()
	server.create_server(port,max_players)
	multiplayer.multiplayer_peer = server

func init_api_scrapping():
	timers.fill_es_clima_api_timer.start()

func _on_player_connected(player_id):
	print("Player " + str(player_id) + " connected")
	player_verification.start(player_id)

func _on_player_disconnected(player_id):
	print("Player " + str(player_id) + " disconnected")
	# AQUI HABRIA QUE GUARDAR LOS DATOS?
	var node = get_node(str(player_id))
	if node != null:
		node.queue_free()

@rpc("any_peer", "reliable")
func _on_data_retrieved(_data:Dictionary):
	pass

@rpc("any_peer","reliable")
func fetch_token(player_id:int) -> void:
	print("Fetching token from " + str(player_id))
	rpc_id(player_id, "give_token")
	
@rpc("any_peer","reliable")
func give_token() -> void:
	pass

@rpc("any_peer","reliable")
func return_token(token:String) -> void:
	print("Token received")
	var player_id = multiplayer.get_remote_sender_id()
	player_verification.verify(player_id, token)


@rpc("any_peer", "reliable")
func _get_data(savefile:String):
	print("Recibida peticion de datos")
	var player_id : int = multiplayer.get_remote_sender_id()
	HubConnection.get_player_savefile(savefile, player_id)

func _on_token_expiration_timeout() -> void:
	if expected_tokens.size() == 0:
		return
	
	var cur_time : int = int(Time.get_unix_time_from_system())
	var token_time : int
	for i in range(expected_tokens.size() -1, -1, -1):
		token_time = int(expected_tokens[i].right(-64))
		if cur_time - token_time >= TOKEN_EXPIRATION_TIME:
			expected_tokens.erase(expected_tokens[i])
	print("Expected: " + str(expected_tokens))

@rpc("any_peer", "reliable")
func return_token_verification_result(player_id:int, token_verification:bool) -> void:
	print("Devolviendo resultado de la verificación del token")
	rpc_id(player_id, "return_token_verification_result", player_id, token_verification)


@rpc("any_peer", "reliable")
func save_data(data:Dictionary, player_id:int = 1) -> void:
	HubConnection.save_game_data(data, player_id)

@rpc("any_peer", "reliable")
func data_saved(result:bool, player_id:int = 1) -> void:
	print("Se ha guardado la partida de " + str(player_id) + ", devolviendo resultado")
	rpc_id(player_id, "data_saved", result)

@rpc("any_peer", "reliable")
func return_savefile(savefile_data:Dictionary, player_id:int, exito:bool) -> void:
	print("Enviando savefile a " + str(player_id))
	rpc_id(player_id, "return_savefile", savefile_data, player_id, exito)
