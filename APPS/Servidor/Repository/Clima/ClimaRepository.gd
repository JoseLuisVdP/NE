extends Node
class_name ClimaRepository

@onready var _DAO : DAO = %MongoDBClimaDAO

func create(data:Dictionary, collection:String, docName:String) -> Dictionary:
	return _DAO.create(data, collection, docName)

func get_first_data(collection:String) -> Dictionary:
	return _DAO.read_first_data(collection)

func get_first_data_name(collection:String) -> String:
	return _DAO.read_first_data_name(collection)

func get_last_data(collection:String) -> Dictionary:
	return _DAO.read_last_data(collection)

func get_last_data_name(collection:String) -> String:
	return _DAO.read_last_data_name(collection)

func get_data(collection:String, id:String) -> Dictionary:
	return _DAO.read(collection, id)

func exists(collection:String, id:String) -> bool:
	return _DAO.has_data(collection, id)
