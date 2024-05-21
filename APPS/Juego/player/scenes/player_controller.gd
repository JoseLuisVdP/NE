class_name Controller extends Node

@onready var _player : Player = $".."

signal open_inventory(inventory:Inventory)

func _unhandled_input(event):
	if event.is_action_released("run"):
		_player.change_state("walking")
	if event.is_action_pressed("up") || event.is_action_pressed("down") || event.is_action_pressed("left") || event.is_action_pressed("right"):
		_player.mvmtKeysPressed += 1
	if event.is_action_released("up") || event.is_action_released("down") || event.is_action_released("left") || event.is_action_released("right"):
		_player.mvmtKeysPressed -= 1
	if event.is_action_pressed("pick_up"):
		if _player.pickable_objects.size() > 0:
			_player.change_state("pickingUpAnItem")
		elif _player.npcs.size() > 0 and not _player.state_machine.is_chatting:
			_player.change_state("chatting")
			_player.start_conversation()
	if event.is_action_pressed("jump") and _player.is_on_floor():
		_player.change_state("jumping")
	if event.is_action_pressed("atack"):
		_player.change_state("hitting")

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("run"):
		_player.change_state("running")
