class_name GameServer extends Node

var client

var token

var ip = "127.0.0.1"
var port = 1909

signal is_data_saved
signal data_retrieved

var data_loaded : bool
var data : Dictionary
var auto_save_scene : PackedScene
var auto_save

signal is_data_loaded

var player_email : String

func _ready() -> void:
	pass

func connect_to_server():
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
	client = ENetMultiplayerPeer.new()
	client.create_client(ip, port)
	multiplayer.multiplayer_peer = client

func _on_connected():
	print("Conectado al servidor")

func _on_connection_failed():
	print("Falló la conexión al servidor")
	if auto_save != null:
		remove_child(auto_save)
		auto_save.queue_free()
		auto_save = null

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
	#Manejar el resultado WIP


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
