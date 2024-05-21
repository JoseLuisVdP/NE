class_name SQLiteGameDAO extends DAO

var DB

func _ready():
	DB = SQLite.new()
	DB.path = "res://now_earth.db"
	DB.open_db()

func create(data:Dictionary, table:String, id:String = "-1") -> Dictionary:
	var temp = DB.insert_row(table,data)
	if temp:
		return data
	else:
		return {}

func read(table:String, id:String, args:String = "[*]") -> Dictionary:
	var result : Dictionary = DB.select_rows(table, "id = "+id, args)
	if result.size() == 0:
		return {}
	return result[0]

func read_all(table:String, where:String="1=1", args:String = "[*]") -> Array[Dictionary]:
	var temp = DB.query("SELECT " + args.replace("[", "").replace("]", "") + " FROM " + table + " WHERE " + where)
	if temp:
		return DB.query_result
	else:
		return [{}] 

func update(new_data:Dictionary, table:String, id:String) -> Dictionary:
	var res : Dictionary = read(table, id)
	if res.size() == 0:
		return {}
	var temp = DB.update_rows(table, "id = "+id, new_data)
	if temp:
		return res
	else:
		return {}

func delete(table:String, id:String) -> Dictionary:
	var res : Dictionary = read(table, id)
	if res.size() == 0:
		return {}
	var temp = DB.delete_rows(table, "id = "+id)
	if temp:
		return res
	else:
		return {}

func has_data(table:String, id:String) -> bool:
	var res : Dictionary = read(table, id)
	return res.size() != 0
