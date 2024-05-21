class_name FilledItemsGrid extends ItemsGrid

func display_filled(items:Array, max_size:int) -> void:
	var diff = max_size - items.size()
	display(items)
	for i in diff:
		var slot = item_slot.instantiate()
		slot.set_slot_size(_item_slot_size)
		add_child(slot)
		slot.display(null)
