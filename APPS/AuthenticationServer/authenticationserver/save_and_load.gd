class_name SaveAndLoad extends Node

@onready var repositories: Repository = %Repository
@export var default_img : CompressedTexture2D

func save_game(data:Dictionary, player_id:int, server_id:int) -> void:
	var player_db_id : int = repositories.GAME_REPOSITORY.get_email_player_id(data["Players"]["mail"])
	var exito : bool = true
	if player_db_id == -1:
		printerr("Ha fallado el guardado de los datos: no existe el jugador")
		exito = false
	else:
		data["SaveFiles"]["NPCs"] = JSON.stringify(data["SaveFiles"]["NPCs"])
		print(data["SaveFiles"]["NPCs"])
		print()
		var savefile_data : Dictionary = data["SaveFiles"]
		var temp = repositories.GAME_REPOSITORY.save_savefile(str(player_db_id), savefile_data)
		if temp.size() == 0:
			printerr("Ha fallado el guardado de los datos")
			exito = false
	GameServer.game_data_saved(exito, player_id, server_id)

func load_game(savefile:String, player_id:int, server_id:int) -> void:
	print("Loading game")
	var exito = true
	#SAVEFILE ES EL MAIL DEL PLAYER POR AHORA
	var savefile_data : Dictionary = repositories.GAME_REPOSITORY.get_savefile_by_email(savefile, savefile)
	
	if savefile_data.size() == 0:
		printerr("Ha fallado el guardado por email, requiere revisar DB")
		exito = false
	
	if savefile_data.keys().has("NPCs") and savefile_data["NPCs"] != null and not savefile_data["NPCs"].is_empty():
		savefile_data["NPCs"] = JSON.parse_string(savefile_data["NPCs"])
	
	GameServer.return_player_savefile(savefile_data, player_id, server_id, exito)


# A PARTIR DE AQUÍ ES TODO DE PRUEBA, NADA DE ESTO ESTÁ EN FUNCIONAMIENTO #
# NO HACER CASO #
@rpc("any_peer", "reliable")
func save_log(player_name:String, save_file_name:String, log:Dictionary):
	var player_id : int = repositories.GAME_REPOSITORY.get_player_id(player_name)
	if player_id == -1:
		printerr("Ha fallado el guardado del log: no existe el jugador")
		return
		
	var savefile_id = repositories.GAME_REPOSITORY.get_savefile_id(str(player_id), save_file_name)
	if savefile_id == -1:
		printerr("Ha fallado el guardado del log: no existe la savefile")
		return
	
	var temp = repositories.GAME_REPOSITORY.save_log(str(player_id), str(savefile_id), log)
	if temp.size() == 0:
		printerr("Ha fallado el guardado de los datos")

@rpc("any_peer", "reliable")
# NOT TESTED WIP
func save_player(name:String, mail:String, password:String, img:PackedByteArray = PackedByteArray()):
	if repositories.GAME_REPOSITORY.player_exists(name):
		printerr("El jugador ya existe")
		return
	
	if repositories.GAME_REPOSITORY.player_mail_exists(mail):
		printerr("El correo ya existe")
		return
	
	var image : PackedByteArray = img
	if image.size() == 0:
		image = default_img.get_image().save_png_to_buffer()
	
	var temp = repositories.GAME_REPOSITORY.save_player({"name":name, "mail":mail, "password":password, "img":image})
	if temp.size() == 0:
		printerr("Ha fallado el guardado de los datos")
