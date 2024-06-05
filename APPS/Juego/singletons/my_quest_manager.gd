class_name MY_QUEST_MANAGER extends Node

static var player : Player
var quests : Dictionary

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
	QuestSystem.start_quest(quest)


func accept_quest(quest:Quest):
	QuestSystem.start_quest(quest)


func complete():
	var quest : Quest = player.chatting_npc.npc.quest
	quest.objective_completed = true
	QuestSystem.complete_quest(quest)


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
	var npc_quests : Array = npc_paths.map(func (i): return get_node(i).npc.quest)
	var npc_quest_names : Array = npc_quests.map(func (i): return i.quest_name)

	for i in quests:
		var pool : Array[Quest] = quests[i]
		for j in pool:
			var idx : int = npc_quest_names.find(j.quest_name)
			if idx != -1:
				get_node(npc_paths[idx]).npc.quest = j
			add_quest(j)
	
	var temp : Array = quests_active
	temp.append_array(quests_completed)
	
	for i in temp:
		accept_quest(i)
	
	for i in quests_completed:
		i.objective_completed = true
		QuestSystem.complete_quest(i)
	
	return data
