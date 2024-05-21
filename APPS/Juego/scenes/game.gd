class_name GAME extends Node3D

@export var _all_recipes_rg:ResourceGroup
@export var _all_items_rg:ResourceGroup
@export var _all_quests_rg:ResourceGroup
var RECIPES : Array[Recipe] = []
var ITEMS : Array[Pickup] = []
var QUESTS : Array[Quest] = []
@onready var player: Player
@onready var my_island: MyIsland = $"3D/World/my_island"

signal loaded
signal data_retrieved

var data : Dictionary

func _ready():
	player = find_child("Player")
	_all_recipes_rg.load_all_into(RECIPES)
	_all_items_rg.load_all_into(ITEMS)
	_all_quests_rg.load_all_into(QUESTS)
	QuestMio.load_quests(self)

func pre_load():
	await data_retrieved
	print(get_node("/root").get_children(true))
	for i in get_node("/root").get_children(true):
		if i.has_method("loaddata"):
			i.loaddata({})
	my_island.generate()
	loaded.emit()
