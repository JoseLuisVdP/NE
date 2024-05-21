class_name ViewOnlyItemSlot extends ColorRect

var _item : Item
@onready var margin_container = %IconContainer
@onready var icon_container = %IconContainer

@export var item_scene:PackedScene

var size_icon : int = -1

var index : int

var is_active : bool = false

func display(item:Pickup, qty:int = 1) -> void:
	if is_active:
		color = Color.hex(0x003333ff)
	else:
		color = Color.hex(0x000000ff)
	if item == null:
		color.a = 0.6
	else:
		if _item == null:
			var scene : Item = item_scene.instantiate()
			icon_container.add_child(scene)
			_item = scene
		color.a = 1
		_item.set_item(item, qty)
		#_item.set_position(Vector2.ZERO)

func set_slot_size(s:int) -> void:
	size_icon = s
	if size_icon != -1:
		custom_minimum_size = Vector2.ONE * size_icon
		if margin_container != null:
			for i in ["margin_bottom","margin_top","margin_left","margin_right"]:
				margin_container.add_theme_constant_override(i, size_icon / 10)
