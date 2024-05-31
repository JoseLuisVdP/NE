class_name Interactible extends Control

@onready var content = %Content

func _ready():
	hide()

func draw_player_pickable_items(item) -> void:
	add_item(item)
	show()

func remove_player_pickable_items(item) -> void:
	remove_item(item)
	if is_empty(): hide()

func is_empty() -> bool:
	return content.get_children().size() == 0

func add_item(item) -> void:
	var item_label = Label.new()
	item_label.text = item.name
	if item is NPC:
		item_label.add_theme_color_override("font_color", Color(0.3,1,0.3))
	content.add_child(item_label)
	content.add_child(HSeparator.new())

func remove_item(item) -> void:
	var labels = content.get_children()
	var lbl = labels.filter(func (i): if i is Label: return i).filter(func(label:Label): return label.text == item.name).pop_front()
	var idx = labels.find(lbl)
	if idx != -1:
		content.remove_child(lbl)
		if labels.size() > idx+1:
			content.remove_child(labels[idx+1])

func close():
	print("close inventory")
	hide()
