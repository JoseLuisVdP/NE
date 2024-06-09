extends Node

@export var player_container_scene : PackedScene
@onready var server: Server = $".."

var awaiting_verification = {}

func start(player_id:int):
	awaiting_verification[player_id] = {"timestamp":int(Time.get_unix_time_from_system())}
	server.fetch_token(player_id)

func verify(player_id:int, token:String):
	print("Verifying player")
	var v : bool = false
	var t = token.right(-64)
	print(t)
	print(int(Time.get_unix_time_from_system()))
	print(int(Time.get_unix_time_from_system()) - int(t))
	print("Expected: " + str(server.expected_tokens))
	while int(Time.get_unix_time_from_system()) - int(t) <= 30:
		if server.expected_tokens.has(token):
			print("El token se encuentra en los esperados por el servidor")
			v = true
			create_player_container(player_id)
			awaiting_verification.erase(player_id)
			server.expected_tokens.erase(token)
			break
		else:
			print("El token NO se encuentra en los esperados por el servidor. Reintentando")
			await get_tree().create_timer(2).timeout
	print("Devolviendo resultado de verify token")
	server.return_token_verification_result(player_id, v)
	
	if not v:
		print("Eliminando el token por ser inválido")
		awaiting_verification.erase(player_id)
		server.server.disconnect_peer(player_id)

func create_player_container(player_id:int) -> void:
	print("Creando contenedor " + str(player_id))
	var player_container = player_container_scene.instantiate()
	player_container.name = str(player_id)
	get_parent().add_child(player_container, true)
	player_container = get_node_or_null("../" + str(player_id))
	if player_container == null:
		return
	fill_player_container(player_container)
	print("Contenedor creado para " + str(player_id))
	

func fill_player_container(player_container:PlayerContainer):
	print("Rellenando datos del jugador de parte del servidor con datos de prueba")
	printerr("ESTO NO SE ESTÁ UTILIZANDO, PUEDES QUITARLO")
	player_container.data = ServerData.test_data


func _on_verification_expiration_timeout() -> void:
	print("Awaiting verification: " + str(awaiting_verification))
	if awaiting_verification.size() == 0:
		return
	
	var cur_time : int = int(Time.get_unix_time_from_system())
	var start_time : int
	for i in awaiting_verification.keys():
		print("Verificando por tiempo a " + str(i))
		start_time = awaiting_verification[i]["timestamp"]
		if cur_time - start_time >= server.TOKEN_EXPIRATION_TIME:
			print("Eliminando a " + str(i))
			awaiting_verification.erase(i)
			var connected_peers : Array = Array(server.multiplayer.get_peers())
			if connected_peers.has(i):
				server.return_token_verification_result(i, false)
				server.server.disconnect_peer(i)
