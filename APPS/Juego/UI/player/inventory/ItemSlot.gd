class_name ItemSlot extends PanelContainer

var _item : Item
@onready var margin_container = %IconContainer
@onready var icon_container = %IconContainer
@onready var grid: OrderedItemsGrid = $".."

@export var item_scene:PackedScene

var ui : UI

var size_icon : int = -1

var index : int

var is_active : bool = false
var active_stylebox : StyleBoxFlat
var default_stylebox : StyleBoxFlat

func _ready():
	"""
	default_stylebox = get_theme_stylebox("normal")
	default_stylebox.border_color = Color(0.6,0.6,0.6)
	default_stylebox.set_border_width_all(1)
	active_stylebox = default_stylebox.duplicate()
	active_stylebox.border_color = Color.WHITE
	"""
	ui = find_parent("UI")

func display(item:Pickup, qty:int = 1) -> void:
	"""
	if is_active:
		add_theme_stylebox_override("normal", active_stylebox)
	else:
		add_theme_stylebox_override("normal", default_stylebox)
	"""
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
		print("CLICK")
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
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if _item != null:
				if _item._item.type == "food":
					ui.player.receive_damage(_item._item.damage)
					ui.player.remove_item(_item._item, 1)
					# _item.add_qty(-1)
					# Curar y luego eliminar 1
