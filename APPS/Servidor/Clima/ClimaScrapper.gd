extends HTTPRequest
## Takes data from AEMET API
class_name ClimaScrapper

## Timer that sets a cooldown for retrying when ERROR=0 (happends often when bad internet connection)
@onready var cooldown : Timer = %Cooldown

## The URL from which the info is taken
var _URL : String = "https://opendata.aemet.es/opendata"

## The API's exact page where the info is available. Variables are represented by $i, where i is the variable's index
var _PAGE : String = "/api/valores/climatologicos/diarios/datos/fechaini/$0/fechafin/$1/todasestaciones"

## Stores body response from requests before they are processed
var _temp_data

## TODO: API_KEY is not safe here
## API_KEY used for getting the data
const _API_KEY : String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJqb3NlbHVpc3ZhbGxlam9kZWxwb3pvQGdtYWlsLmNvbSIsImp0aSI6ImZjOTU4MGY4LThlYzQtNDkzNi04MWRjLTVhZmQ3Y2EwY2NjMyIsImlzcyI6IkFFTUVUIiwiaWF0IjoxNzEyOTE1MDkxLCJ1c2VySWQiOiJmYzk1ODBmOC04ZWM0LTQ5MzYtODFkYy01YWZkN2NhMGNjYzMiLCJyb2xlIjoiIn0.MwDhXiS9mnqODvr_KbvWV3kuF0tgzY1cvZV4hzhFiAM"

## Gets an array of clima data for a certain date (YYYY-mm-dd) from different stations
## If data is not received, waits _retry_cooldown to try again
## If it's, data is retrieved from link "datos"
## Then, data is returned

func _ready() -> void:
	use_threads = true
	max_redirects = 20
	timeout = 1

func request_climatologia(collection:String, date:String):
	_temp_data = null
	match collection:
		"es":
			var request = null
			while request == null:
				request = await request_es_climatologia(date)
				
			var response = null
			var url = _temp_data["datos"]
			_temp_data = null
			while response == null:
				response = await get_es_climatologia(url)
			print("Datos obtenidos!")
			return response
		_:
			print("LA COLECCION " + collection + " NO TIENE METODO")
			return []

func request_es_climatologia(date:String):
	var url : String = _URL + fill_page_variables(_PAGE, [date + "T00:00:00UTC", date + "T23:00:00UTC"])
	if _temp_data == null || _temp_data.is_empty():
		request(url, ["accept: application/json", "api_key: " + _API_KEY], HTTPClient.METHOD_GET)
		await request_completed
		
		# 1s cooldown
		cooldown.start()
		await cooldown.timeout
		
		print(_temp_data)
	return _temp_data

func get_es_climatologia(url:String):
	print("Obteniendo datos")
	request(url)
	await request_completed
		
	# 1s cooldown
	cooldown.start()
	await cooldown.timeout
	return _temp_data

## Signal received by the httpRequest
## Stores recived data in a Dictionary only if all goes well
func _on_request_completed(result, response_code, headers, body) -> void:
	_temp_data = null
	
	if response_code == 200: print("Lectura EXITOSA")
	elif response_code == 0: print("Error 0"); return
	else: printerr("Algo ha ido MAL (err: " + str(response_code) + ")"); return
		
	_temp_data = JSON.parse_string(body.get_string_from_ascii())

## Fills variables, replacing $i by values[i]
func fill_page_variables(url:String, values:Array[String]) -> String:
	var result = url
	for i in values.size():
		result = result.replace("$"+str(i), values[i])
	return result
