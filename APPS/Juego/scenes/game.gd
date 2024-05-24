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

signal loaded

var data_loaded : bool = false

func _ready():
	# POR AHORA, EL NOMBRE VA A SER EL CORREO
	var savefile = Server.player_email
	Server._get_data(savefile)
	
	await Server.is_data_loaded

	player = find_child("Player")
	_all_recipes_rg.load_all_into(RECIPES)
	_all_items_rg.load_all_into(ITEMS)
	_all_quests_rg.load_all_into(QUESTS)
	QuestMio.load_quests(self)

func pre_load():
	print("Pre carga")
	print(get_node("/root").get_children(true))
	if data_loaded:
		print("Se ha encontrado un archivo de guardado, cargando...")
		for i in get_node("/root").get_children(true):
			if i.has_method("loaddata"):
				i.loaddata({})
	else:
		print("No se ha encontrado un archivo de guardado, creando nueva partida")
	my_island.generate()
	loaded.emit()
