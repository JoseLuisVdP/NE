class_name GAME extends Node3D

@export var _all_recipes_rg:ResourceGroup
@export var _all_items_rg:ResourceGroup
@export var _all_quests_rg:ResourceGroup

var RECIPES : Array[Recipe] = []
var ITEMS : Array[Pickup] = []
var QUESTS : Array[Quest] = []

@onready var player: Player
@onready var my_island: MyIsland = $"3D/World/my_island"
@onready var ui: UI = $UI

var loaded : bool


func _ready():
	# El nombre será el correo, pero el sistema admite nombres personalizados para tener más de una partida
	var savefile = Server.player_email
	Server._get_data(savefile)
	
	await Server.is_data_loaded

	load_saved_data()
	player = find_child("Player")
	_all_items_rg.load_all_into(ITEMS)
	_all_recipes_rg.load_all_into(RECIPES)
	_all_quests_rg.load_all_into(QUESTS)
	Commons.ITEMS = ITEMS
	Commons.RECIPES = RECIPES
	Commons.QUESTS = QUESTS
	MyQuestManager.check_win_condition()
	MyQuestManager.load_quests(self)
	if not Server.data["SaveFiles"].keys().has("time"):
		GlobalTime.iniciar(0, $"3D/Lights/Sunlight", $"3D/Lights/Moonlight")
	else:
		GlobalTime.iniciar(Server.data["SaveFiles"]["time"], $"3D/Lights/Sunlight", $"3D/Lights/Moonlight")
	if not Server.data_loaded:
		player.add_item(ITEMS.filter(func (i:Pickup): return i.name == "Hacha")[0], 1)
	


func pre_load():
	print("Pre carga")
	await my_island.generate()
	loaded = true


func load_saved_data():
	if Server.data_loaded:
		print("Se ha encontrado un archivo de guardado, cargando...")
		for i in get_tree().get_nodes_in_group("save_and_load"):
			if i.has_method("loaddata"):
				i.loaddata(Server.data)
		if Server.data["SaveFiles"].keys().has("quests") and Server.data["SaveFiles"]["quests"] != null:
			MyQuestManager.loaddata(Server.data)
		
	else:
		print("No se ha encontrado un archivo de guardado, creando nueva partida")


# Calcula el clima, y devuelve la temperatura
func update_clima():
	if Server.clima_data.is_empty():
		print("Aun no hay datos")
		return
	
	var data = Server.clima_data[player.location][GlobalTime.cur_day - 1]["ALMERIA"]["CABO DE GATA"]
	var time : int = GlobalTime.day_time_formated
	
	var hora_max = data["hora_max"].split(":")
	if hora_max.size() != 2:
		return
	hora_max = int(hora_max[0]) * 60 + int(hora_max[1])
	hora_max *= 60
	
	var hora_min = data["hora_min"].split(":")
	if hora_min.size() != 2:
		return
	hora_min = int(hora_min[0]) * 60 + int(hora_min[1])
	hora_min *= 60
	
	var hora_avg = hora_min + (hora_max - hora_min/2)
	
	var temp_max : float = float(data["temp_max"])
	var temp_min : float = float(data["temp_min"])
	var temp_avg : float = float(data["temp_avg"])
	
	var hora_avg_end_in_s = max(GlobalTime.DAY - GlobalTime.DAY / 8, hora_min - GlobalTime.DAY / 8)
	
	if GlobalTime.is_between(hora_min, hora_max):
		player.temperature = calculate_temp(hora_min, hora_max, temp_min, temp_max)
	elif GlobalTime.is_between(hora_max, hora_avg):
		player.temperature = calculate_temp(hora_max, hora_avg, temp_max, temp_avg)
	elif GlobalTime.is_between(hora_avg, hora_avg_end_in_s):
		player.temperature = temp_avg
	elif GlobalTime.is_between(hora_avg_end_in_s, hora_min):
		player.temperature = calculate_temp(hora_avg_end_in_s, hora_min, temp_avg, temp_min)
	
	ui.update_temp()
	
	if player.temperature < 10:
		for i in get_tree().get_nodes_in_group("chimney"):
			i.show()
	else:
		for i in get_tree().get_nodes_in_group("chimney"):
			i.hide()

func calculate_temp(begin, end, temp_inicio, temp_final):
	var time_left : float
	if GlobalTime.day_time > end:
		time_left = GlobalTime.DAY - GlobalTime.day_time + end
	else:
		time_left = end - GlobalTime.day_time
		
	var total : float
	if begin > end:
		total = GlobalTime.DAY - begin + end
	else:
		total = end - begin
	var progress : float = time_left/total
	var temp_diff = temp_final - temp_inicio
	return temp_inicio + (temp_diff - temp_diff * progress)
