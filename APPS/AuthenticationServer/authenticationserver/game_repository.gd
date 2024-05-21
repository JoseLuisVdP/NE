class_name GameRepository extends Node

@onready var _DAO : DAO = %SQLiteGameDAO

func save_player(player_data:Dictionary) -> Dictionary:
	return _DAO.create(player_data, "Players")

func save_savefile(player_id:String, savefile_data:Dictionary) -> Dictionary:
	savefile_data["id_player"] = player_id
	return _DAO.create(savefile_data, "SaveFiles")

func get_player(player_name:String) -> Dictionary:
	var player_id : int = get_player_id(player_name)
	if player_id == -1:
		return {}
	return _DAO.read("Players", str(player_id))

func get_email_player(player_email:String) -> Dictionary:
	var player_id : int = get_email_player_id(player_email)
	if player_id == -1:
		return {}
	return _DAO.read("Players", str(player_id))

func get_savefile(player_name:String, savefile_name:String) -> Dictionary:
	var player_id : int = get_player_id(player_name)
	if player_id == -1:
		return {}
	var res : Dictionary = _DAO.read_all("SaveFiles", "id_player = '" + str(player_id) + "' AND name = '" + savefile_name + "'")[0]
	if res.size()==0:
		return {}
	return res

func player_exists(player_name:String) -> bool:
	return get_player(player_name).size() != 0

func player_email_exists(player_email:String) -> bool:
	var a = _DAO.read_all("Players", "mail = '" + player_email + "'")
	return a.size() > 0

func player_password_is_correct(player_email:String, password:String) -> bool:
	var player : Dictionary = get_email_player(player_email)
	return player["password"] == password

func get_save_files(player_name:String) -> Array[Dictionary]:
	var player_id : int = get_player_id(player_name)
	return _DAO.read_all("SaveFiles", "id_player = '" + str(player_id) + "'")

func get_player_id(player_name:String) -> int:
	var temp : Dictionary = _DAO.read_all("Players", "name = '" + player_name + "'", ["id"])[0]
	if temp.size() == 0:
		return -1
	return temp["id"]

func get_email_player_id(player_email:String) -> int:
	var temp : Dictionary = _DAO.read_all("Players", "mail = '" + player_email + "'", ["id"])[0]
	if temp.size() == 0:
		return -1
	return temp["id"]

func get_savefile_id(player_id:String, savefile_name:String) -> int:
	var temp : Array[Dictionary] = _DAO.read_all("SaveFiles", "id_player = '" + player_id + "' AND name = '" + savefile_name + "'", ["id"])
	if temp[0].size() == 0:
		return -1
	return temp[0]["id"]

func save_log(player_id:String, savefile_id:String, log_data:Dictionary) -> Dictionary:
	log_data["id_player"] = player_id
	log_data["id_savefile"] = savefile_id
	return _DAO.create(log_data, "Logs")
