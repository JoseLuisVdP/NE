class_name ItemSlot extends ReferenceRect

var _item : Item
var inventory
@onready var margin_container = %IconContainer
@onready var icon_container = %IconContainer
@onready var grid: OrderedItemsGrid = $".."
@onready var reference_rect: ReferenceRect = %ReferenceRect

@export var item_scene:PackedScene

var ui : UI

var size_icon : int = -1

var index : int

var is_active : bool = false

func _ready():
	ui = find_parent("UI")
	inventory = grid.inventory

func display(item:Pickup, qty:int = 1) -> void:
	if is_active:
		reference_rect.show()
	else:
		reference_rect.hide()
	if item != null:
		if _item == null:
			var scene : Item = item_scene.instantiate()
			icon_container.add_child(scene)
			_item = scene
		_item.set_item(item, qty)
		#_item.set_position(Vector2.ZERO)

func set_slot_size(s:int) -> void:
	size_icon = s
	if size_icon != -1:
		custom_minimum_size = Vector2.ONE * size_icon
		for i in ["margin_bottom","margin_top","margin_left","margin_right"]:
			margin_container.add_theme_constant_override(i, size_icon / 10)

func pickItem() -> void:
	if ui.picked_item != null:
		ui.remove_child(ui.picked_item)
	
	icon_container.remove_child(_item)
	
	ui.picked_item = _item
	ui.item_slot = self
	ui.add_child(ui.picked_item)
	
	_item = null
	display(null)
	
	grid.inventory.delete_item(index)

func putItem() -> void:
	if _item != null:
		icon_container.remove_child(_item)
		
	_item = ui.picked_item
	
	ui.remove_child(_item)
	ui.picked_item = null
	ui.item_slot = null
	
	icon_container.add_child(_item)
	
	display(_item._item, _item._qty)
	
	grid.inventory.store_item(_item._item, _item._qty, index)

func interchange_item():
	if _item == null || ui.picked_item == null:
		print("Err: intento de intercambio de items con alguna variable nula")
		return
	
	var temp = ui.picked_item
	var temp_slot = ui.item_slot
	pickItem()
	
	_item = temp
	ui.item_slot = temp_slot
	icon_container.add_child(_item)
	
	display(_item._item, _item._qty)
	
	grid.inventory.store_item(temp._item, temp._qty, index)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if ui.picked_item != null:
				if _item == null:
					putItem()
				else:
					if ui.picked_item._item != _item._item:
						interchange_item()
					else:
						var able_to_add = _item._item.stack_size - _item._qty
						if able_to_add == 0:
							interchange_item()
						elif able_to_add - ui.picked_item._qty >= 0:
							_item.add_qty(ui.picked_item._qty)
							
							grid.inventory.delete_item(ui.item_slot.index)
							grid.inventory.delete_item(index)
							grid.inventory.store_item(_item._item, _item._qty, index)
							
							ui.picked_item.queue_free()
							ui.picked_item = null
						else:
							_item.add_qty(able_to_add)
							ui.picked_item.add_qty(-able_to_add)
							
							grid.inventory.delete_item(ui.item_slot.index)
							grid.inventory.delete_item(index)
							grid.inventory.store_item(_item._item, _item._qty, index)
			elif _item != null:
				pickItem()
