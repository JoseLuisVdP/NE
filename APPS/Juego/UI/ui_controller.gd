extends Node

@onready var ui: UI = $".."

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate_toolbar"):
		rotate_tool()
	if event.is_action_pressed("inventory"):
		var check = false
		for i in ui.closeable.get_children(false):
			if i is Control and i.is_visible_in_tree():
				check = true
				i.close()
		if check:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return
		ui.inventory()
	if event.is_action_pressed("crafting"):
		ui.crafting()
	if event.is_action_pressed("camera_toggle"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_released("camera_toggle"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if ui.picked_item != null:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			ui.picked_item.set_global_position(get_viewport().get_mouse_position() - ui.picked_item.size/2)
			ui.picked_item.z_index = 999
		else:
			if ui.item_slot.icon_container.get_children().is_empty():
				ui.item_slot.putItem()
			else:
				#Drop item
				pass

func rotate_tool():
	var prev_index : int = ui.player.toolbar.active_slot
	var max : int = ui.player.toolbar._max_size
	if ui.player.toolbar.active_slot + 1 >= max:
		ui.player.toolbar.active_slot = 0
	else:
		ui.player.toolbar.active_slot += 1
	var index : int = ui.player.toolbar.active_slot
	var slot : ItemSlot = ui.toolbar.content.get_child(index)
	var prev_slot : ItemSlot = ui.toolbar.content.get_child(prev_index)
	prev_slot.is_active = false
	slot.is_active = true
	var prev_item = prev_slot._item
	var item = slot._item
	
	var hand : BoneAttachment3D = ui.player.tools_attatchment
	if not hand.get_children().is_empty():
		hand.remove_child(hand.get_child(0))
	if prev_item != null:
		prev_slot.display(prev_item._item, prev_item._qty)
		ui.player.equip_tool(null)
	else:
		prev_slot.display(null)
	if item != null:
		slot.display(item._item, item._qty)
		var tool : RigidBody3D = item._item.scene.instantiate()
		tool.collision_mask = 0
		hand.add_child(tool)
		ui.player.equip_tool(item._item)
	else:
		slot.display(null)
	ui.toolbar.update_active_item_lbl()
