extends Node
## Main class for server functionality
class_name Server
@onready var player_verification: Node = %PlayerVerification

var server

var port = 1909
var max_players = 5

## Timers
@onready var timers : Timers = %Timers
@onready var repositories: Repository = %Repositories

@export var default_img : CompressedTexture2D

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
	# AQUI HABRIA QUE GUARDAR LOS DATOS
	get_node(str(player_id)).queue_free()


@rpc("any_peer", "reliable")
func get_data():
	var player_id : int = multiplayer.get_remote_sender_id()
	var data : Dictionary = get_node(str(player_id)).data
	rpc_id(player_id,"_on_data_retrieved", data)

@rpc("any_peer", "reliable")
func _on_data_retrieved(_data:Dictionary):
	pass
