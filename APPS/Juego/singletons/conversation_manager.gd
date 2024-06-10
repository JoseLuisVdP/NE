class_name CONVERSATION_MANAGER extends Node


# El NPC con el que estas hablando. Se almacena para evitar errores en caso de salir de la zona de diálogo
var cur_talker : NPCScene
var sea_song : AudioStreamPlayer


# Variables que almacenan el estado de las misiones
var has_10_wheat_10_turnip_10_carrot : bool
var has_axe : bool
var are_the_boys_found : bool = false
var boys_founded : int = 0
var has_bread : bool
var has_turnip_soup : bool
var has_mushroom_soup : bool
var has_5_suspicious_mushrooms : bool
var is_village_free_of_rats : bool
var has_2_rope_10_stick : bool
var has_20_stones : bool


func end_chat():
	if cur_talker == null:
		return
	cur_talker.stop_talking()
	cur_talker = null


# Actualiza los estados de las misiones
func update_objectives():
	update_quest_not_enough()
	has_axe = MyQuestManager.player.has_all_items([Commons.ITEMS.filter(func (x): return "Hacha" == x.name)[0]])
	has_bread = MyQuestManager.player.has_all_items([Commons.ITEMS.filter(func (x): return "Pan" == x.name)[0]])
	has_turnip_soup = MyQuestManager.player.has_all_items([Commons.ITEMS.filter(func (x): return "Sopa de rabano" == x.name)[0]])
	has_mushroom_soup = MyQuestManager.player.has_all_items([Commons.ITEMS.filter(func (x): return "Sopa de seta" == x.name)[0]])
	update_quest_drugs()
	update_quest_carter()
	update_quest_in_gods_name()


func update_quest_not_enough():
	var temp : Array[Pickup] = []
	var things_to_add : Array[String] = ["Trigo", "Rabano", "Zanahoria"]
	for i in things_to_add:
		var item : Pickup = Commons.ITEMS.filter(func (x): return i == x.name)[0]
		for j in range(10):
			temp.append(item.duplicate())
	has_10_wheat_10_turnip_10_carrot = MyQuestManager.player.has_all_items(temp)


func update_quest_drugs():
	var temp : Array[Pickup] = []
	var things_to_add : Array[String] = ["Seta sospechosa"]
	for i in things_to_add:
		var item : Pickup = Commons.ITEMS.filter(func (x): return i == x.name)[0]
		for j in range(5):
			temp.append(item.duplicate())
	has_5_suspicious_mushrooms = MyQuestManager.player.has_all_items(temp)


func update_quest_carter():
	var temp : Array[Pickup] = []
	var things_to_add : Array[String] = ["Cuerda"]
	for i in things_to_add:
		var item : Pickup = Commons.ITEMS.filter(func (x): return i == x.name)[0]
		for j in range(2):
			temp.append(item.duplicate())
	
	things_to_add = ["Palo"]
	for i in things_to_add:
		var item : Pickup = Commons.ITEMS.filter(func (x): return i == x.name)[0]
		for j in range(10):
			temp.append(item.duplicate())
	
	has_2_rope_10_stick = MyQuestManager.player.has_all_items(temp)


func update_quest_in_gods_name():
	var temp : Array[Pickup] = []
	var things_to_add : Array[String] = ["Piedra"]
	for i in things_to_add:
		var item : Pickup = Commons.ITEMS.filter(func (x): return i == x.name)[0]
		for j in range(20):
			temp.append(item.duplicate())
	
	has_20_stones = MyQuestManager.player.has_all_items(temp)


func play_sea_song():
	sea_song.play()


func stop_sea_song():
	sea_song.stop()


func force_save():
	Server.auto_save.save()


func teleport():
	Scenes.load_scene("credits")
	pass


func end_chat_and_despawn():
	cur_talker.stop_talking()
	cur_talker.queue_free()
	cur_talker = null


func add_boy_founded():
	boys_founded += 1
	if boys_founded == 2:
		are_the_boys_found = true
