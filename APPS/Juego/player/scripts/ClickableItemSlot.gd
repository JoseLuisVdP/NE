class_name ClickableItemSlot extends ItemSlot

var item_displayed : Pickup
@onready var button = %Button

signal pressed_item(item:Pickup)

#Reassign variables
func _ready():
	icon_container = button
	margin_container = %MarginContainer
	super._ready()

func display(item:Pickup, qty = 1):
	super.display(item)
	if item != null: item_displayed = item
	else: button.disabled = true

func _on_pressed():
	pressed_item.emit(item_displayed)
