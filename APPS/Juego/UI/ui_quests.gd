class_name UIQuests extends Control

@onready var label: Label = $Label
@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer

var content : Dictionary

func _ready() -> void:
	QuestSystem.new_available_quest.connect(add_quest)
	QuestSystem.quest_accepted.connect(accept_quest)
	QuestSystem.quest_completed.connect(complete_quest)
	
	update_text()

func _process(delta: float) -> void:
	pass

func add_quest(quest: Quest):
	update_text()

func accept_quest(quest : Quest):
	update_text()

func complete_quest(quest : Quest):
	update_text()

func update_text():
	for pool in QuestSystem.quests_as_dict():
		var lbl = v_box_container.get_children().filter(func (i): return i.name == pool)
		if lbl.size() == 0:
			lbl = Label.new()
			lbl.name = pool
			v_box_container.add_child(lbl)
		else:
			lbl = lbl[0]
		lbl.text = pool.to_upper() + ": \n"
		for i in QuestSystem.quests_as_dict()[pool]:
			var quest : Quest = QuestSystem.get_children().filter(func (i): return i.name.to_lower() == pool)[0].get_quest_from_id(i)
			lbl.text += "  "+quest.quest_name + " - " + str(quest.objective_completed) + "\n"
			lbl.text += "    -" + quest.quest_objective
