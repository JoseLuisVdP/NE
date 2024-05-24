extends Button



func _on_pressed() -> void:
	Server.auto_save.save()
