extends DAO
class_name MongoDBClimaDAO

var CLIENT
var DB

# La colección sale fuera debido a que, por el funcionamiento del conector, trata de cargar totalmente la colección en lugar de permitir filtrar.
# Esto deberá ser adaptado si en un futuro se pretende introducir más climas además del español, pero implicaría el desarrollo de un conector personalizado más óptimo en C++ o C#
# Dado que se sale del alcance del proyecto, optaré por esta forma de optimizar el proceso
var col = null
var docs : Array = []

## Day in unix time
const UNIX_DAY : int = 86400

func _ready():
	CLIENT = MongoAPI.Connect(MongoAPI.host)
	DB = CLIENT.GetDatabase("clima")

func create(data:Dictionary, collection:String, docName:String = "-1") -> Dictionary:
	if !DB.GetCollectionsNameList().has(collection):
		printerr("LA COLECCION " + collection + " NO EXISTE, CREANDO...")
		DB.CreateCollection(collection)
	
	var col = DB.GetCollection(collection)
	col.InsertDocument(data, docName)
	return data


func read(collection:String, id:String, args:String = ""):
	if !DB.GetCollectionsNameList().has(collection):
		print("No existe la colección " + collection)
	if col == null:
		col = DB.GetCollection(collection)
	if docs.is_empty():
		docs = col.GetDocuments()
	var result : Array = docs.duplicate(true)
	if result == null or result.is_empty():
		return {}
	return result.filter(func (doc): return doc["_id"] == id)[0]


func read_month(collection:String, month:String) -> Array:
	if !DB.GetCollectionsNameList().has(collection):
		print("No existe la colección " + collection)
	if col == null:
		col = DB.GetCollection(collection)
	if docs.is_empty():
		docs = col.GetDocuments()
	var result : Array = docs.duplicate(true)
	if result == null or result.is_empty():
		return [{}]
		var a : String = ""
		a.erase(0, a.length()-3)

	result = result.filter(func (doc): return doc["_id"].erase(doc["_id"].length()-3, 3).ends_with("2023-"+month))
	result.sort_custom(func (a, b): return a["_id"].erase(0, a["_id"].length()-3) < b["_id"].erase(0, b["_id"].length()-3))
	return result


func has_data(collection:String, docName:String) -> bool:
	if !DB.GetCollectionsNameList().has(collection):
		print("No existe la colección " + collection)
		return false
	
	var col = DB.GetCollection(collection)
	var results : Array = col.GetDocumentsName()
	return results.has(docName)

func read_first_data(collection:String) -> Dictionary:
	var id : String = read_first_data_name(collection)
	var col = DB.GetCollection(collection)
	return col.GetDocument(id)

func read_first_data_name(collection:String) -> String:
	if !collectionExists(collection): return ""
	
	var col = DB.GetCollection(collection)
	var results : Array = col.GetDocumentsName()
	
	if results.is_empty(): return ""
	
	results = results.map(func(i:String): return Time.get_unix_time_from_datetime_string(i))
	results.sort()
	
	return Time.get_date_string_from_unix_time(results[results.size()-1])

func read_last_data(collection:String) -> Dictionary:
	var id : String = read_last_data_name(collection)
	var col = DB.GetCollection(collection)
	return col.GetDocument(id)

func read_last_data_name(collection:String) -> String:
	if !collectionExists(collection): return ""
	
	var col = DB.GetCollection(collection)
	var results : Array = col.GetDocumentsName()
	
	if results.is_empty(): return ""
	
	results = results.map(func(i:String): return Time.get_unix_time_from_datetime_string(i))
	results.sort()
	
	var last_day : int = results[0]
	var day : int = results[-1]
	# Comprobamos que no haya huecos entre medias
	for i in results:
		last_day = day
		day -= UNIX_DAY
		if not results.has(day):
			break
	
	return Time.get_date_string_from_unix_time(last_day)

func collectionExists(collection:String) -> bool:
	return DB.GetCollectionsNameList().has(collection)
