class_name UI extends CanvasLayer

@onready var _inventory : InventoryDialog = %Inventory
@onready var _pickable_items = %PickableItems
@onready var _crafting : CraftingDialog = %Crafting
@onready var game: GAME = $".."
@onready var player: Player = $"../3D/Player"
@onready var hotbar: Hotbar = %Hotbar
@onready var toolbar: Toolbar = %Toolbar
@onready var stats: UIStats = %Stats
@onready var quests: UIQuests = %Quests

@onready var closeable: Node = $Closeable
@onready var non_closeable: Node = $NonCloseable

var picked_item : Item
var item_slot : ItemSlot

func _ready() -> void:
	_inventory.set_inventory(player.inventory)
	hotbar.set_inventory(player.hotbar)
	toolbar.set_inventory(player.toolbar)
	
	_inventory.content.set_active_slot(player.inventory.active_slot)
	hotbar.content.set_active_slot(player.hotbar.active_slot)
	toolbar.content.set_active_slot(1)
	toolbar.update_active_item_lbl()
	
	hotbar.open(player.hotbar)
	toolbar.open(player.toolbar)

func _on_player_in_area(item):
	_pickable_items.draw_player_pickable_items(item)

func _on_player_not_in_area(item):
	_pickable_items.remove_player_pickable_items(item)

func inventory() -> void:
	var player_inventory : Inventory = player.inventory
	_inventory.open(player_inventory)

func crafting() -> void:
	if not _crafting.is_visible_in_tree():
		inventory()
		_crafting.open(game.RECIPES, player.inventory)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
