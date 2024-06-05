class_name CLIMA extends Node


var timer : Timer


func inicializar():
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 15
	timer.timeout.connect(update_clima)


func update_clima():
	pass
