class_name UIQuests extends Control


@onready var active : VBoxContainer = %Active
@onready var completed: VBoxContainer = %Completed


var content : Dictionary
var quest_nodes : Dictionary

func _ready() -> void:
	QuestSystem.new_available_quest.connect(add_quest)
	QuestSystem.quest_accepted.connect(accept_quest)
	QuestSystem.quest_completed.connect(complete_quest)
	
	var lbl = Label.new()
	lbl.name = "active"
	lbl.text = "Misiones actuales:"
	active.add_child(lbl)
	
	var lbl2 = Label.new()
	lbl2.name = "completed"
	lbl2.text = "Misiones completadas:"
	completed.add_child(lbl2)
	
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
	for i in QuestSystem.get_active_quests():
		var quest : Quest = i
		
		var quest_container := VBoxContainer.new()
		quest_container.add_theme_constant_override("separation", 16)
		
		var quest_name_and_more := HBoxContainer.new()
		quest_name_and_more.add_theme_constant_override("separation", 8)
		
		var details := Label.new()
		details.text = "Objetivo: " + quest.quest_objective
		details.text += "\n"
		details.text += "Descripción: " + quest.quest_description
		details.hide()
		
		var name := Label.new()
		name.text = quest.quest_name
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var more := Button.new()
		more.set_meta("details", details)
		more.pressed.connect(func (): more.get_meta("details").visible = not more.get_meta("details").visible)
		more.text = "+"
		more.size = Vector2.ONE * 24
		
		quest_name_and_more.add_child(name)
		quest_name_and_more.add_child(more)
		quest_container.add_child(quest_name_and_more)
		quest_container.add_child(details)
		active.add_child(quest_container)
		
		quest_nodes[quest] = quest_container
	
	for i in QuestSystem.get_completed_quests():
		var quest : Quest = i
		var lbl := Label.new()
		lbl.text = quest.quest_name
		completed.add_child(lbl)
		
		if QuestSystem.is_quest_completed(quest):
			active.remove_child(quest_nodes[quest])
			quest_nodes[quest].queue_free()
		
		quest_nodes[quest] = lbl
	

"""
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
			lbl.text += "\n"
"""
