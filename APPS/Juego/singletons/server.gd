class_name GameServer extends Node

var client

var token

var ip = "54.243.133.143"
var port = 1909

signal is_data_saved
signal data_retrieved

var data_loaded : bool
var data : Dictionary
var clima_data : Dictionary = {}
const clima_places : Dictionary = {"pradollano":"MALAGA-MARBELLA", "sandy":"ALMERIA-CABO DE GATA", "monmonty":"PONTEVEDRA-A LAMA"}
var auto_save_scene : PackedScene
var auto_save
var connection_up : bool = false
var test_connection_timer : Timer

signal is_data_loaded

var player_email : String

func _ready() -> void:
	test_connection_timer = Timer.new()
	test_connection_timer.wait_time = 20
	test_connection_timer.timeout.connect(test_connection)
	add_child(test_connection_timer)

func connect_to_server():
	if not multiplayer.connected_to_server.is_connected(_on_connected):
		multiplayer.connected_to_server.connect(_on_connected)
	
	if not multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.connect(_on_connection_failed)
	
	client = ENetMultiplayerPeer.new()
	client.create_client(ip, port)
	multiplayer.multiplayer_peer = client

func _on_connected():
	print("Conectado al servidor")
	connection_up = true
	test_connection()

func _on_connection_failed():
	print("Falló la conexión al servidor")
	if auto_save != null:
		remove_child(auto_save)
		auto_save.queue_free()
		auto_save = null


@rpc("any_peer", "reliable")
func get_clima(year:int, month:int, places:Dictionary):
	rpc_id(1, "get_clima_data", year, month, places)


@rpc("any_peer", "reliable")
func get_clima_data(year:int, month:int, places:Dictionary):
	pass


@rpc("any_peer", "reliable")
func clima_data_received(data:Dictionary, player_id:int):
	clima_data = data


@rpc("any_peer", "reliable")
func _on_data_retrieved(_data:Dictionary):
	data_retrieved.emit()

@rpc("any_peer","reliable")
func give_token() -> void:
	print("Requesting token, sending")
	rpc_id(1, "return_token", token)

@rpc("any_peer","reliable")
func fetch_token(player_id:int = 1) -> void:
	pass

@rpc("any_peer","reliable")
func return_token(token:String) -> void:
	pass

@rpc("any_peer", "reliable")
func return_token_verification_result(player_id:int, token_verification:bool) -> void:
	print("Resultado de la verificación del token:")
	var login : LoginScreen = Gateway.login_node
	if token_verification:
		print("Token verificado")
		player_email = login.email
		login.get_parent().queue_free()
		Scenes.load_scene("game")
		auto_save = auto_save_scene.instantiate()
		add_child(auto_save)
		#auto_save.start()
		auto_save.process_thread_group = Node.PROCESS_THREAD_GROUP_SUB_THREAD
	else:
		print("Login fallido (token malo)")
		login.login_btn.disabled = false
		login.register_btn.disabled = false


@rpc("any_peer", "reliable")
func save_data(data:Dictionary, player_id : int = 1) -> void:
	player_id = multiplayer.get_unique_id()
	rpc_id(1, "save_data", data, player_id)


@rpc("any_peer", "reliable")
func data_saved(result:bool, player_id:int = 1) -> void:
	auto_save.saved = result
	is_data_saved.emit()


@rpc("any_peer", "reliable")
func _get_data(savefile:String):
	print("Getting data")
	rpc_id(1, "_get_data", savefile)


@rpc("any_peer", "reliable")
func return_savefile(savefile_data:Dictionary, player_id:int, exito:bool) -> void:
	print("Savefile received")
	data_loaded = exito
	data["SaveFiles"] = savefile_data
	data["Players"] = {"mail":player_email}
	is_data_loaded.emit()


@rpc("any_peer", "reliable")
func test_connection():
	if connection_up:
		connection_up = false
		test_connection_timer.start()
		rpc_id(1, "test_connection")
	else:
		var window : Window = Window.new()
		window.always_on_top = true
		window.close_requested.connect(func (): get_tree().quit())
		window.size = Vector2(400, 250)
		window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
		var lbl := Label.new()
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.text = "La conexión con el servidor se ha perdido\nProcure guardar a menudo para evitar perder datos"
		window.add_child(lbl)
		add_child(window)
		get_tree().paused = true


@rpc("any_peer", "reliable")
func test_connection_result():
	connection_up = true
