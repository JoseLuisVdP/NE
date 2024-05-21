extends Timer
class_name FillClimaAPITimer

## Last date used to store data
var date : String
@export var collection : String

@onready var timers : Timers = $".."
@onready var http_request: ClimaScrapper = %HTTPRequest

## Stores last data retrieved
var _data_cache : Dictionary = {}

## Stores last date retrieved
var _date_cache : String = ""

## Day in unix time
const UNIX_DAY : int = 86400

func _ready():
	var unix : int = Time.get_unix_time_from_system()
	date = Time.get_date_string_from_unix_time(unix - (UNIX_DAY * 7))

func subtract_day() -> void:
	var unix = Time.get_unix_time_from_datetime_string(date) - UNIX_DAY
	date = Time.get_date_string_from_unix_time(unix)

## Task for retrieving and storing [ES] clima data
func fill_clima_api() -> void:
	stop()
	
	if timers.server.repositories.CLIMA.exists(collection, date):
		print("APIClima ("+collection+"): " + date + " already exists!")
		come_back_to_tail()
	
	print("APIClima ("+collection+"): " + date)
	var data = await get_data(collection, date)
	timers.server.repositories.CLIMA.create(data, collection, date)
	subtract_day()
	
	start()

func come_back_to_tail():
	var last_data_name : String = timers.server.repositories.CLIMA.get_last_data_name(collection)
	date = last_data_name
	subtract_day()
	print("Saltando a " + date)

## Retrieves ES clima info
func get_data(collection:String, date:String) -> Dictionary:
	if _date_cache != date:
		var dataArray : Array = await http_request.request_climatologia(collection, date)
		_data_cache = _process_clima_data(collection, dataArray)
		_date_cache = date
	else: print("Taking data from cache (" + date + ")")
	return _data_cache

func _process_clima_data(collection:String, data:Array) -> Dictionary:
	match collection:
		"es":
			return _process_es_clima_data(data)
		_:
			print("NO EXISTE LA FUNCION PARA PROCESAR ESA INFO")
			return {}

## Filters and organices info
func _process_es_clima_data(data:Array) -> Dictionary:
	var docName : String
	var processedData : Dictionary = {}
	for i:Dictionary in data:
		var provincia : String = i["provincia"]
		var estacion : String = i["nombre"]
		docName = i["fecha"]
		i.erase("indicativo")
		i.erase("provincia")
		i.erase("fecha")
		i.erase("nombre")
		if !processedData.has(provincia):
			processedData[provincia] = {}
		processedData[provincia][estacion] = i
	return processedData
