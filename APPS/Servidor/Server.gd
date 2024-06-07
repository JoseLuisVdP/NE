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

@rpc("any_peer", "reliable")
func get_clima_data(year:int, month:int, places:Dictionary):
	var result : Dictionary
	var clima_data : Dictionary = {}
	var date : String = str(year) + "-"
	
	if month < 10:
		date += "0" + str(month)
	else:
		date += str(month)
	date += "-"
	
	var stations : Array = []
	
	var places_array : Array = []
	for i in places:
		var place : String = places[i]
		var station = place.split("-")[1]
		place = place.split("-")[0]
		stations.append(station)
		places_array.append(place)
		clima_data[i] = []
	
	for i in places:
		var place : String = places[i]
		var station = place.split("-")[1]
		place = place.split("-")[0]
		
		for j in range(0, 28):
			var string : String
			if j < 9:
				string = date + "0" + str(j+1)
			else:
				string = date + str(j+1)
			var data : Dictionary = {}
			data = repositories.CLIMA.get_data("es", string)
			if data == null or data.is_empty():
				clima_data_received({}, multiplayer.get_remote_sender_id())
				return
			if not clima_data.keys().has(i):
				clima_data[i] = []
			data_pre_processing(data, places_array, stations)
			clima_data[i].append(data)
	
	for i in places:
		var place : String = places[i]
		var station = place.split("-")[1]
		place = place.split("-")[0]
		for j in clima_data[i].size():
			clima_data[i][j] = data_processing(clima_data[i][j], place, station)
	
	clima_data_received(clima_data, multiplayer.get_remote_sender_id())


@rpc("any_peer", "reliable")
func get_clima(year:int, month:int, places:Dictionary):
	pass


@rpc("any_peer", "reliable")
func clima_data_received(data:Dictionary, player_id:int):
	rpc_id(player_id, "clima_data_received", data, player_id)


func data_pre_processing(data:Dictionary, places:Array, stations:Array):
	for i in data.keys():
		if not places.has(i):
			data.erase(i)
		else:
			for j in data[i]:
				if not stations.has(j):
					data[i].erase(j)
	return data

func data_processing(data:Dictionary, place:String, station:String):
	print("a")
	data[place][station].erase("altitud")
	data[place][station].erase("dir")
	data[place][station].erase("horaHrMax")
	data[place][station].erase("horaHrMin")
	data[place][station].erase("horaracha")
	data[place][station].erase("hrMax")
	data[place][station].erase("hrMedia")
	data[place][station].erase("hrMin")
	data[place][station].erase("racha")
	data[place][station].erase("velmedia")
	if data[place][station].keys().has("tmed"):
		data[place][station]["temp_avg"] = data[place][station]["tmed"]
		data[place][station]["temp_max"] = data[place][station]["tmax"]
		data[place][station]["temp_min"] = data[place][station]["tmin"]
		data[place][station]["hora_max"] = data[place][station]["horatmax"]
		data[place][station]["hora_min"] = data[place][station]["horatmin"]
		data[place][station].erase("horatmax")
		data[place][station].erase("horatmin")
		data[place][station].erase("tmed")
		data[place][station].erase("tmax")
		data[place][station].erase("tmin")
	return data
