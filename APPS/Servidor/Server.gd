class_name Server extends Node
## Main class for server functionality

@onready var player_verification: Node = %PlayerVerification

var server

var port = 1909
var max_players = 5

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

@rpc("any_peer","reliable")
func fetch_token(player_id:int) -> void:
	rpc_id(player_id, "fetch_token", player_id)


@rpc("any_peer","reliable")
func return_token(token:String) -> void:
	var player_id = multiplayer.get_remote_sender_id()
	player_verification.verify(player_id, token)


@rpc("any_peer", "reliable")
func get_data():
	var player_id : int = multiplayer.get_remote_sender_id()
	var data : Dictionary = get_node(str(player_id)).data
	rpc_id(player_id,"_on_data_retrieved", data)

@rpc("any_peer", "reliable")
func _on_data_retrieved(_data:Dictionary):
	pass

func _on_token_expiration_timeout() -> void:
	if expected_tokens.size() == 0:
		return
	
	var cur_time : int = int(Time.get_unix_time_from_system())
	var token_time : int
	for i in range(expected_tokens.size() -1, -1, -1):
		token_time = int(expected_tokens[i].right(64))
		if cur_time - token_time >= TOKEN_EXPIRATION_TIME:
			expected_tokens.erase(i)
	print(expected_tokens)

@rpc("any_peer", "reliable")
func return_token_verification_result(player_id:int, token_verification:bool) -> void:
	print("Devolviendo resultado de la verificación del token")
	rpc_id(player_id, "return_token_verification_result", player_id, token_verification)
