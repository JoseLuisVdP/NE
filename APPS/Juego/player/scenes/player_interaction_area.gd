class_name PlayerInteractionArea extends Area3D

@onready var _player: Player = $".."

func _on_area_entered(area: Area3D) -> void:
	print("_entered - " + str(area))
	var body = area.get_parent()
	if body == null: return
	
	var parent = body.get_parent()
	if parent == null: return
	if parent is PickupScene:
		print("Puedo pillar " + parent.item.name)
		_player.pickable_objects.append(parent)
		_player.in_area.emit(parent.item)
	elif parent is NPCScene:
		print("NPC: " + parent.npc.name)
		_player.npcs.append(parent)
		_player.in_area.emit(parent.npc)

func _on_area_exited(area: Area3D) -> void:
	print("_exited - " + str(area))
	var body = area.get_parent()
	if body == null: return
		
	var parent = body.get_parent()
	if parent == null: return
	
	if parent is PickupScene:
		_player.pickable_objects.erase(parent)
		_player.not_in_area.emit(parent.item)
	if parent is NPCScene:
		_player.npcs.erase(parent)
		_player.not_in_area.emit(parent.npc)
