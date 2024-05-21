class_name MyQuestManager extends Node

static var player : Player

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

func complete():
	var quest : Quest = player.chatting_npc.npc.quest
	quest.objective_completed = true
	QuestSystem.complete_quest(quest)

func load_quests(game:GAME):
	for quest in game.QUESTS:
		print(quest)
		add_quest(quest)
