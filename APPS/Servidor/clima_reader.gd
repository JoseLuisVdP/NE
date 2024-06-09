extends Node

@onready var repositories: Repository = %Repositories
@onready var server: Server = $".."


var thread: Thread = null
var mutex:Mutex


func _ready() -> void:
	mutex = Mutex.new()


func get_clima_data(year, month, places, player_id):
	thread = Thread.new()
	mutex.lock()
	thread.start(_background_get_clima_data.bind(year, month, places, player_id))
	mutex.unlock()


func _background_get_clima_data(year:int, month:int, places:Dictionary, player_id:int):
	var result : Dictionary
	var clima_data : Dictionary = {}
	var str_month : String
	
	if month < 10:
		str_month = "0" + str(month)
	else:
		str_month = str(month)
	
	var stations : Array = []
	
	var places_array : Array = []
	for i in places:
		var place : String = places[i]
		var station = place.split("-")[1]
		place = place.split("-")[0]
		stations.append(station)
		places_array.append(place)
		clima_data[i] = []
	
	#repositories.CLIMA.call_deferred("get_month_data", "es", str_month)
	var full_data = repositories.CLIMA.get_month_data("es", str_month)
	
	for i in places:
		var place : String = places[i]
		var station = place.split("-")[1]
		place = place.split("-")[0]
		
		for j in range(0, 28):
			var string : String

			var data : Dictionary = {}
			data = full_data[j]
			if data == null or data.is_empty():
				server.call_deferred("clima_data_received",{}, player_id)
				return
			if not clima_data.keys().has(i):
				clima_data[i] = []
				#places_array[clima_data.keys().find(i)]
			data_pre_processing(data, places_array, stations)
			clima_data[i].append(data.duplicate())
	
	for i in places:
		var place : String = places[i]
		var station = place.split("-")[1]
		place = place.split("-")[0]
		for j in clima_data[i].size():
			clima_data[i][j] = data_processing(clima_data[i][j], place, station)
	
	# Forma parte de la optimización temporal tomada en el DAO para acelerar la lectura del clima
	repositories.CLIMA._DAO.docs = []
	server.call_deferred("clima_data_received",clima_data, player_id)
	
	thread.wait_to_finish()
	thread = null


func data_pre_processing(data:Dictionary, places:Array, stations:Array):
	for i in data.keys():
		if not places.has(i):
			data.erase(i)
		else:
			for j in data[i]:
				if not stations.has(j):
					data[i].erase(j)
	return data


func data_processing(data:Dictionary, place:String, station:String):
	data[place][station].erase("altitud")
	data[place][station].erase("dir")
	data[place][station].erase("horaHrMax")
	data[place][station].erase("horaHrMin")
	data[place][station].erase("horaracha")
	data[place][station].erase("hrMax")
	data[place][station].erase("hrMedia")
	data[place][station].erase("hrMin")
	data[place][station].erase("racha")
	data[place][station].erase("velmedia")
	if data[place][station].keys().has("tmed"):
		data[place][station]["temp_avg"] = data[place][station]["tmed"]
		data[place][station]["temp_max"] = data[place][station]["tmax"]
		data[place][station]["temp_min"] = data[place][station]["tmin"]
		data[place][station]["hora_max"] = data[place][station]["horatmax"]
		data[place][station]["hora_min"] = data[place][station]["horatmin"]
		data[place][station].erase("horatmax")
		data[place][station].erase("horatmin")
		data[place][station].erase("tmed")
		data[place][station].erase("tmax")
		data[place][station].erase("tmin")
	return data
