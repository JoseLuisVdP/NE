class_name GameRepository extends Node

@onready var _DAO : DAO = %SQLiteGameDAO

func save_player(player_data:Dictionary) -> Dictionary:
	randomize()
	var salt = str(randi()).sha256_text()
	var hashed_password = hash_password_sha256(player_data["password"], salt)
	player_data["password"] = hashed_password
	player_data["salt"] = salt
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

func get_savefile_by_email(player_mail:String, savefile_name:String) -> Dictionary:
	var player_id : int = get_email_player_id(player_mail)
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
	if player.size() == 0:
		return false
	return verify_password_sha256(password, player["password"], player["salt"])

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


func verify_password_sha256(password:String, hash:String, salt:String) -> bool:
	var hashed = hash_password_sha256(password, salt)
	return hashed == hash

func verify_password_bcrypt(password: String, hashed_password: String) -> bool:
	var args = ["bcrypt.py", "verify", password, hashed_password]
	var data : Array = []
	var result = OS.execute("python", args, data, true)
	print(data)
	if result != 0:
		print("Falla el bcrypt")
		return false
	else:
		return true


func hash_password_sha256(password:String, salt:String) -> String:
	var rounds = pow(2,3)
	var hashed_password = password
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	
	return hashed_password


func hash_password_bcrypt(password:String) -> String:
	var args : PackedStringArray = ["bcrypt.py", "hash", password]
	var data_hash : Array = []
	var hashing = OS.execute("python", args, data_hash, true)
	if hashing != 0:
		print("Falla el bcrypt")
		return ""
	print(data_hash)
	return data_hash[1].strip_edges()
