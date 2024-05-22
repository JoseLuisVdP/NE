extends Node

@export var player_container_scene : PackedScene
@onready var server: Server = $".."

var awaiting_verification = {}

func start(player_id:int):
	awaiting_verification[player_id] = {"timestamp":int(Time.get_unix_time_from_system())}
	server.fetch_token(player_id)

func verify(player_id:int, token:String):
	var v : bool = false
	var t = token.right(-64)
	print(t)
	print(int(Time.get_unix_time_from_system()))
	print(int(Time.get_unix_time_from_system()) - int(t))
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
	server.return_token_verification_result(player_id, v)
	
	if not v:
		awaiting_verification.erase(player_id)
		server.server.disconnect_peer(player_id)

func create_player_container(player_id:int) -> void:
	var player_container = player_container_scene.instantiate()
	player_container.name = str(player_id)
	get_parent().add_child(player_container, true)
	player_container = get_node("../" + str(player_id))
	fill_player_container(player_container)

func fill_player_container(player_container:PlayerContainer):
	player_container.data = ServerData.test_data


func _on_verification_expiration_timeout() -> void:
	print("Awaiting verification: " + str(awaiting_verification))
	if awaiting_verification.size() == 0:
		return
	
	var cur_time : int = int(Time.get_unix_time_from_system())
	var start_time : int
	for i in awaiting_verification.keys():
		start_time = awaiting_verification[i]["timestamp"]
		if cur_time - start_time >= server.TOKEN_EXPIRATION_TIME:
			awaiting_verification.erase(i)
			var connected_peers : Array = Array(server.multiplayer.get_peers())
			if connected_peers.has(i):
				server.return_token_verification_result(i, false)
			server.server.disconnect_peer(i)
