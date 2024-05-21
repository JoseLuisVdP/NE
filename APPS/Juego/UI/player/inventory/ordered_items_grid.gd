class_name OrderedItemsGrid extends GridContainer

var inventory
@export_enum("64:64", "60:60", "56:56", "52:52", "48:48", "44:44", "40:40", "36:36", "32:32", "28:28", "24:24", "20:20", "16:16") var _item_slot_size : int

func _ready() -> void:
	var acc = 0
	for i in get_children():
		var slot : ItemSlot = i
		slot.index = acc
		acc+=1
		slot.set_slot_size(_item_slot_size)
		slot.display(null)

func display(items:Dictionary) -> void:
	for item in items:
		var slot : ItemSlot = get_children()[item]
		slot.set_slot_size(_item_slot_size)
		slot.display(items[item][0], items[item][1])

func set_active_slot(idx:int):
	if idx == -1:
		for i in get_children():
			i.is_active = false
	else:
		get_child(idx).is_active = true
		var item : Item = get_child(idx)._item
		if item == null:
			get_child(idx).display(null)
		else:
			get_child(idx).display(item._item, item._qty)
