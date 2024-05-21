class_name InventoryDialog extends Control

@onready var content : OrderedItemsGrid = %InventoryContent
@onready var ui: UI = $"../.."

func set_inventory(inv:Inventory) -> void:
	content.inventory = inv

func _ready():
	hide()
	pass

func _on_close_btn_pressed() -> void:
	ui._crafting.close()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	close()

func close():
	print("close inventory")
	if ui.item_slot != null and ui.item_slot.icon_container.get_children().is_empty():
		ui.item_slot.putItem()
	else:
		#Drop item
		pass
	hide()

func open(inventory:Inventory) -> void:
	print("open inventory")
	content.display(inventory.get_content())
	show()

func _on_btn_crafting_pressed():
	ui.crafting()
