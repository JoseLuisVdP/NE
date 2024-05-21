class_name Toolbar extends Control

@onready var content : OrderedItemsGrid = %Content
@onready var active_item: RichTextLabel = %ActiveItem
@onready var ui: UI = $"../.."

func update_active_item_lbl() -> void:
	var active_slot : int = ui.player.toolbar.active_slot
	var item : Item = content.get_child(active_slot)._item
	if item == null:
		active_item.text = " "
	else:
		active_item.text = item._item.name

func set_inventory(inv:Inventory) -> void:
	content.inventory = inv

func close():
	print("close hotbar")
	hide()

func open(hotbar:Inventory) -> void:
	print("open hotbar")
	content.display(hotbar.get_content())
	show()
