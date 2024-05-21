extends Node
class_name DAO

func create(data:Dictionary, collection:String, docName:String = "-1") -> Dictionary:
	printerr("NO HAS IMPLEMENTADO ESTA FUNCION")
	return {}

func read(collection:String, docName:String, args:Array[String] = ["*"]) -> Dictionary:
	printerr("NO HAS IMPLEMENTADO ESTA FUNCION")
	return {}

func read_first_data(collection:String) -> Dictionary:
	printerr("NO HAS IMPLEMENTADO ESTA FUNCION")
	return {}

func read_first_data_name(collection:String) -> String:
	printerr("NO HAS IMPLEMENTADO ESTA FUNCION")
	return ""

func read_last_data(collection:String) -> Dictionary:
	printerr("NO HAS IMPLEMENTADO ESTA FUNCION")
	return {}

func read_last_data_name(collection:String) -> String:
	printerr("NO HAS IMPLEMENTADO ESTA FUNCION")
	return ""

func read_all(collection:String, where:String = "1=1", args:Array[String] = ["*"]) -> Array[Dictionary]:
	printerr("NO HAS IMPLEMENTADO ESTA FUNCION")
	return [{}]

func update(new_data:Dictionary, collection:String, docName:String) -> Dictionary:
	printerr("NO HAS IMPLEMENTADO ESTA FUNCION")
	return {}

func delete(collection:String, docName:String) -> Dictionary:
	printerr("NO HAS IMPLEMENTADO ESTA FUNCION")
	return {}

func has_data(collection:String, docName:String) -> bool:
	printerr("NO HAS IMPLEMENTADO ESTA FUNCION")
	return false
