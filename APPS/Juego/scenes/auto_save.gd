extends Timer

@onready var game: GAME = $".."

var saved : bool = false
"""
func save():
	stop()
	for i in get_tree().get_children():
		if (i as Node).has_method("savedata"):
			game.data = i.savedata(game.data)
		await get_tree().process_frame
	#Guardado local vendría bien WIP
	Server.save_data(game.data)
	await Server.is_data_saved
	print("¡Datos guardados ("+ str(saved) +")!")
	saved = false
	start()

func _on_timeout() -> void:
	save()
"""
