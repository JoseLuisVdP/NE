extends Timer

var saved : bool = false

func _ready() -> void:
	stop()

func save():
	print("Saving game")
	stop()
	for i in get_tree().get_nodes_in_group("save_and_load"):
		if (i as Node).has_method("savedata"):
			print("Saving " + str(i))
			Server.data = i.savedata(Server.data)
		await get_tree().process_frame
	#Guardado local vendría bien WIP
	Server.save_data(Server.data)
	await Server.is_data_saved
	print("¡Datos guardados ("+ str(saved) +")!")
	saved = false
	#start()

func _on_timeout() -> void:
	save()

