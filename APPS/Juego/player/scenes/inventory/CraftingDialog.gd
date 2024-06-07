class_name CraftingDialog extends Control

var _all_items : Array[Pickup] = []

@onready var recipe_list = %RecipeList

@onready var ingredients = %Ingredients
@onready var results = %Results
@onready var btn_craft = %BtnCraft

@onready var more_info = %MoreInfo
@onready var more_ingredients = %MoreIngredients
@onready var more_results = %MoreResults

var ui : UI

var _current_recipe : Recipe

func _ready():
	ui = find_parent("UI")
	hide()
	btn_craft.hide()

func open(recipes:Array[Recipe], inventory:Inventory):
	print("open crafting")
	show()
	
	recipe_list.clear()

	for r in recipes:
		var index = recipe_list.add_item(r.name)
		recipe_list.set_item_icon(index, r.results[0].icon)
		recipe_list.set_item_metadata(index, r)
	
func close():
	print("close crafting")
	for i in ingredients.get_children(false) + results.get_children(false):
		i.queue_free()
	# Esconde el boton de crafteo hasta que se seleccione un crafteo válido
	hide()
	btn_craft.hide()
	
func _on_recipe_list_item_selected(index):
	_current_recipe = recipe_list.get_item_metadata(index)
	refresh_crafting()

func refresh_crafting():
	if _current_recipe != null:
		ingredients.display(_current_recipe.ingredients)
		results.display(_current_recipe.results)
		
		btn_craft.show()
		btn_craft.disabled = not ui.player.has_all_items(_current_recipe.ingredients)

func _on_btn_more_pressed():
	if more_info.is_visible_in_tree():
		more_info.close()
		%BtnMore.text = "+"
	else:
		more_info.open(_all_items)
		%BtnMore.text = "-"

func _on_btn_craft_pressed():
	for i in _current_recipe.ingredients:
		ui.player.remove_item(i, 1)
	for i in _current_recipe.results:
		ui.player.add_item(i, 1)
	
	btn_craft.disabled = not ui.player.has_all_items(_current_recipe.ingredients)

func on_all_items_item_selected(item:Pickup):
	#Obtengo array de todas las recetas que contengan como resultado al item escogido
	var recipes : Array[Recipe] = [_current_recipe]

	#Muestro la receta
	more_ingredients.display(recipes[0].ingredients)
	more_results.display(recipes[0].results)
	#Mostrar receta y resultados del item seleccionado
	#A futuro, paginar diferentes crafteos para el mismo item con el addon de paginate tables
