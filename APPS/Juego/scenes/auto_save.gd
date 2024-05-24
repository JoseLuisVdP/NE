extends Timer

var saved : bool = false

func save():
	print("Saving game")
	stop()
	await save_recursively(get_tree().get_nodes_in_group("save_and_load"), Server.data)
	#Guardado local vendría bien WIP
	print("Data collected: " + str(Server.data))
	Server.save_data(Server.data)
	await Server.is_data_saved
	print("¡Datos guardados ("+ str(saved) +")!")
	saved = false
	start()

func _on_timeout() -> void:
	save()

func save_recursively(children:Array, data:Dictionary):
	for i in children:
		if (i as Node).has_method("savedata"):
			print("Saving " + str(i))
			data = i.savedata(data)
		await get_tree().process_frame
		if i.get_children().size() > 0:
			save_recursively(i.get_children(), data)
