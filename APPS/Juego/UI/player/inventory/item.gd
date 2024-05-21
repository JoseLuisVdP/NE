class_name Item extends Panel

@onready var icon: TextureRect = %Icon
@onready var label: Label = %Label

@export var defaultTexture : Texture2D
var _item : Pickup
var _qty : int

func set_item(item:Pickup = null, qty = 1):
	if item == null:
		_item = null
		icon.texture = defaultTexture
	else:
		_item = item
		_qty = qty
		icon.texture = _item.icon

	if _item.stack_size <= 1:
		label.hide()
	else:
		label.show()
		label.text = str(_qty)

func add_qty(qty = 1):
	_qty += qty
	label.text = str(_qty)
