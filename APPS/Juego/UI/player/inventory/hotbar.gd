class_name Hotbar extends Control

@onready var content : OrderedItemsGrid = %Content
@onready var ui: UI = $"../.."

func set_inventory(inv:Inventory) -> void:
	content.inventory = inv

func close():
	print("close hotbar")
	hide()

func open(hotbar:Inventory) -> void:
	print("open hotbar")
	content.display(hotbar.get_content())
	show()
