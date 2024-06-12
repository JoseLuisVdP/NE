class_name AUTO_SAVE extends Timer

var saved : bool = false
var thread : Thread

func _ready() -> void:
	stop()

func save():
	stop()
	print("Saving game")
	#thread = Thread.new()
	#thread.start(threaded_save)
	for i in get_tree().get_nodes_in_group("save_and_load"):
		if (i as Node).has_method("savedata"):
			print("Saving " + str(i))
			Server.data = i.savedata(Server.data)
		await get_tree().process_frame
	#Guardado local vendría bien WIP
	Server.data["SaveFiles"]["time"] = GlobalTime.time
	Server.data = MyQuestManager.savedata(Server.data)
	Server.save_data(Server.data)
	await Server.is_data_saved
	print("¡Datos guardados ("+ str(saved) +")!")
	saved = false


func threaded_save():
	for i in get_tree().get_nodes_in_group("save_and_load"):
		if (i as Node).has_method("savedata"):
			print("Saving " + str(i))
			call_deferred("save_individual_data", i)
		await get_tree().process_frame
	#Guardado local vendría bien WIP
	Server.data["SaveFiles"]["time"] = GlobalTime.time
	call_deferred("save_individual_data", MyQuestManager)
	Server.save_data(Server.data)
	await Server.is_data_saved
	print("¡Datos guardados ("+ str(saved) +")!")
	saved = false


func save_individual_data(node:Node):
	Server.data = node.savedata(Server.data)


func _on_timeout() -> void:
	save()

