extends Node

@export var player_container_scene : PackedScene

func start(player_id:int):
	"""Verificacion con token WIP"""
	create_player_container(player_id)

func create_player_container(player_id:int) -> void:
	var player_container = player_container_scene.instantiate()
	player_container.name = str(player_id)
	get_parent().add_child(player_container, true)
	player_container = get_node("../" + str(player_id))
	fill_player_container(player_container)

func fill_player_container(player_container:PlayerContainer):
	player_container.data = ServerData.test_data
