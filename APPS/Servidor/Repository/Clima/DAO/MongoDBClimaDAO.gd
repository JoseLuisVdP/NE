extends DAO
class_name MongoDBClimaDAO

var CLIENT
var DB

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
