class_name GAME extends Node3D

@export var _all_recipes_rg:ResourceGroup
@export var _all_items_rg:ResourceGroup
@export var _all_quests_rg:ResourceGroup

var RECIPES : Array[Recipe] = []
var ITEMS : Array[Pickup] = []
var QUESTS : Array[Quest] = []

@onready var player: Player
@onready var my_island: MyIsland = $"3D/World/my_island"
@onready var paths: Node3D = %Paths

var loaded : bool


func _ready():
	# POR AHORA, EL NOMBRE VA A SER EL CORREO
	var savefile = Server.player_email
	Server._get_data(savefile)
	
	await Server.is_data_loaded

	load_saved_data()
	player = find_child("Player")
	_all_recipes_rg.load_all_into(RECIPES)
	_all_items_rg.load_all_into(ITEMS)
	_all_quests_rg.load_all_into(QUESTS)
	MyQuestManager.load_quests(self)
	GlobalTime.iniciar(Server.data["SaveFiles"]["time"], $"3D/Lights/Sunlight", $"3D/Lights/Moonlight")
	

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
