class_name MoreInfo extends Control

@onready var all_items_grid : FilledItemsGrid = %AllItemsGrid

func open(items:Array[Pickup]):
	show()
	var count = ceil(items.size() * 1.0 / all_items_grid.columns)
	all_items_grid.display_filled(items, all_items_grid.columns * count)

func close():
	hide()

func _ready():
	hide()

func _on_btn_close_more_pressed():
	close()
