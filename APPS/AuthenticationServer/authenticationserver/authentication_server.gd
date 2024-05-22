extends Node

@onready var repository: Repository = %Repository
@export var default_img : CompressedTexture2D

var server

var port = 1911
var max_servers = 10

func _ready():
	multiplayer.peer_connected.connect(_on_gateway_connected)
	multiplayer.peer_disconnected.connect(_on_gateway_disconnected)
	
	server = ENetMultiplayerPeer.new()
	server.create_server(port, max_servers)
	multiplayer.multiplayer_peer = server
	
	print("AuthenticationServer started")

func _on_gateway_connected(gateway_id):
	print("Gateway " + str(gateway_id) + " connected")

func _on_gateway_disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " disconnected")


@rpc("any_peer","reliable")
func create_account(email:String, password:String, player_id:int) -> void:
	print("Crear cuenta para usuario " + str(player_id))
	var gateway_id : int = multiplayer.get_remote_sender_id()
	var result : bool = true
	var message : int
	
	if repository.GAME_REPOSITORY.player_email_exists(email):
		printerr("El jugador ya existe")
		message = 2
		result = false
		
	else:
		var image = default_img.get_image().save_png_to_buffer()
		var name = null	# WIP
		
		var temp = repository.GAME_REPOSITORY.save_player({"name":name, "mail":email, "password":password, "img":image})
		if temp.size() == 0:
			printerr("Ha fallado el guardado en la base de datos")
			message = 4
		else:
			print("Jugador guardado")
			message = 3
	
	rpc_id(gateway_id, "create_account_results", result, player_id, message)

@rpc("any_peer", "reliable")
func create_account_results (result:bool, player_id:int, message:int) -> void:
	pass


@rpc("any_peer", "reliable")
func authenticate_player(email:String, password:String, player_id:int):
	print("Authentication request received")
	var token : String
	var gateway_id = multiplayer.get_remote_sender_id()
	var result : bool = false
	if not repository.GAME_REPOSITORY.player_email_exists(email):
		print("No se encuentra el email")
	elif not repository.GAME_REPOSITORY.player_password_is_correct(email, password):
		print("Contraseña incorrecta")
	else:
		print("Autenticación exitosa")
		result = true
		
		randomize()
		token = str(randi()).sha256_text()
		token += str(int(Time.get_unix_time_from_system()))
		# Aquí habría que decidir a qué servidor va (balanceador de carga)
		GameServer.distribute_login_token(token, "GameServer1")
	
	print("Autenticación enviada a gateway")

	rpc_id(gateway_id, "authentication_results", result, player_id, token)

@rpc("any_peer", "reliable")
func authentication_results(result:bool, player_id:int, token:String):
	pass
