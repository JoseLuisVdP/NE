class_name SaveAndLoad extends Node

@onready var repositories: Repository = %Repository
@export var default_img : CompressedTexture2D

@rpc("any_peer", "reliable")
func save_game(player_name:String, save_file:Dictionary):
	var player : int = repositories.GAME_REPOSITORY.get_player_id(player_name)
	if player == -1:
		printerr("Ha fallado el guardado de los datos: no existe el jugador")
		return
	var temp = repositories.GAME_REPOSITORY.save_savefile(str(player), save_file)
	if temp.size() == 0:
		printerr("Ha fallado el guardado de los datos")

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
func save_player(name:String, mail:String, password:String, img:PackedByteArray = PackedByteArray()):
	if repositories.GAME_REPOSITORY.player_exists(name):
		printerr("El jugador ya existe")
		return
	
	var regex : RegEx = RegEx.new()
	regex.compile("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")
	if not regex.search(mail):
		printerr("Correo inválido")
		return
	
	if repositories.GAME_REPOSITORY.player_mail_exists(mail):
		printerr("El correo ya existe")
		return
	
	var image : PackedByteArray = img
	if image.size() == 0:
		image = default_img.get_image().save_png_to_buffer()
	
	var temp = repositories.GAME_REPOSITORY.save_player({"name":name, "mail":mail, "password":password, "img":img})
	if temp.size() == 0:
		printerr("Ha fallado el guardado de los datos")
