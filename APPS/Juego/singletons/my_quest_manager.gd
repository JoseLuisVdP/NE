class_name MY_QUEST_MANAGER extends Node

static var player : Player
var quests : Dictionary
var has_won : bool = false
var children : Array[NPCScene] = []

"""
func a():
	var quest : Quest = Quest.new()
	quest.quest_name = "Prueba"
	quest.quest_description = "Misión de prueba, esto es la descripcion"
	quest.quest_objective = "Objetivo de la quest"
	QuestSystem.mark_quest_as_available(quest)
"""

func add_quest(quest:Quest):
	QuestSystem.mark_quest_as_available(quest)


func accept():
	var quest : Quest = player.chatting_npc.npc.quest
	player.chatting_npc.accept_mission()
	QuestSystem.start_quest(quest)
	remove_quest(quest)


func remove_quest(quest:Quest):
	var temp = QuestSystem.available.quests.filter(func (i): return i.quest_name == quest.quest_name)
	if temp.is_empty():
		return
	QuestSystem.available.remove_quest(temp[0])


func accept_quest(quest:Quest):
	QuestSystem.start_quest(quest)


func spawn_children():
	for i in children:
		i.show()


func complete():
	var quest : Quest = player.chatting_npc.npc.quest
	player.chatting_npc.complete_mission()
	quest.objective_completed = true
	player.money += quest.quest_money
	player.xp += quest.quest_xp
	player.ui.stats.update_stats(player.money, player.xp)
	QuestSystem.complete_quest(quest)
	check_win_condition()
	match quest.quest_name:
		"El accidentado carretero":
			var temp : Pickup = Commons.ITEMS.filter(func (i): return i.name == "Cuerda")[0]
			player.remove_item(temp, 2)
			temp = Commons.ITEMS.filter(func (i): return i.name == "Palo")[0]
			player.remove_item(temp, 10)
		"El otro tipo de seta":
			var temp : Pickup = Commons.ITEMS.filter(func (i): return i.name == "Seta sospechosa")[0]
			player.remove_item(temp, 5)
		"Dame un buen pan":
			var temp : Pickup = Commons.ITEMS.filter(func (i): return i.name == "Pan")[0]
			player.remove_item(temp, 1)
		"Caldo de setas":
			var temp : Pickup = Commons.ITEMS.filter(func (i): return i.name == "Sopa de seta")[0]
			player.remove_item(temp, 1)
		"Deliciosa sopa de rabano":
			var temp : Pickup = Commons.ITEMS.filter(func (i): return i.name == "Sopa de rabano")[0]
			player.remove_item(temp, 1)
		"Los jardines de Dios":
			var temp : Pickup = Commons.ITEMS.filter(func (i): return i.name == "Piedra")[0]
			player.remove_item(temp, 20)
		"Problemas de abastecimiento":
			var temp : Pickup = Commons.ITEMS.filter(func (i): return i.name == "Trigo")[0]
			player.remove_item(temp, 10)
			temp = Commons.ITEMS.filter(func (i): return i.name == "Rabano")[0]
			player.remove_item(temp, 10)
			temp = Commons.ITEMS.filter(func (i): return i.name == "Zanahoria")[0]
			player.remove_item(temp, 10)
	Server.auto_save.save()


func check_win_condition():
	has_won = Commons.QUESTS.size() - 1 <= QuestSystem.get_completed_quests().size()
	player.ui.quests.update_text()



func load_quests(game:GAME):
	for quest in game.QUESTS:
		"""
		var saved_quests = quests["available"]
		saved_quests.append_array(quests["active"])
		saved_quests.append_array(quests["completed"])
		
		if saved_quests.map(func (i): return i.quest_name).has(quest.quest_name):
			quest = saved_quests[0]
		"""
		#add_quest(quest)
		pass



func savedata(data:Dictionary) -> Dictionary:
	data["SaveFiles"]["quests"] = {}
	
	data["SaveFiles"]["quests"]["available"] = var_to_bytes_with_objects(QuestSystem.get_available_quests())
	data["SaveFiles"]["quests"]["active"] = var_to_bytes_with_objects(QuestSystem.get_active_quests())
	data["SaveFiles"]["quests"]["completed"] = var_to_bytes_with_objects(QuestSystem.get_completed_quests())
	
	data["SaveFiles"]["quests"] = var_to_bytes_with_objects(data["SaveFiles"]["quests"])
	
	return data


func loaddata(data:Dictionary) -> Dictionary:
	quests = bytes_to_var_with_objects(data["SaveFiles"]["quests"])
	
	var quests_available : Array[Quest] = bytes_to_var_with_objects(quests["available"])
	var quests_active : Array[Quest] = bytes_to_var_with_objects(quests["active"])
	var quests_completed : Array[Quest] = bytes_to_var_with_objects(quests["completed"])
	
	quests["available"] = quests_available
	quests["active"] = quests_active
	quests["completed"] = quests_completed
	
	var npc_paths : Array = data["SaveFiles"]["NPCs"].keys().map(func (i): return i.erase(i.rfind("/"), 999))
	for i in npc_paths:
		if get_node_or_null(i) == null:
			npc_paths.erase(i)
	var npc_quests : Array = npc_paths.map(func (i): return get_node(i).npc.quest).filter(func (i): return i != null)
	var npc_quest_names : Array = npc_quests.map(func (i): return i.quest_name)

	for i in quests:
		var pool : Array[Quest] = quests[i]
		for j in pool:
			add_quest(j)
			var path : Array = npc_paths.filter(func (i): return aux_filter_quest(i, j))
			if not path.is_empty():
				var npc : NPCScene = get_node(path[0])
				if npc != null and npc.npc.quest != null:
					npc.state_chart.send_event("available")
					if i == "active" or i == "completed":
						npc.accept_mission()
						remove_quest(j)
						
					if i == "completed":
						npc.complete_mission()
						remove_quest(j)
	return data


func aux_filter_quest(npc_path, quest):
	var npc : NPCScene = get_node_or_null(npc_path)
	if npc == null or npc.npc.quest == null:
		return false
	return npc.npc.quest.quest_name == quest.quest_name
