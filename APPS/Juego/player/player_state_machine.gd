class_name PlayerStateMachine extends StateChart

@onready var _player: Player

var is_hitting : bool = false
var is_working : bool = false
var is_chatting: bool = false

func is_moving():
	return _player.mvmtKeysPressed > 0 and not is_hitting and not is_working and not is_chatting

func _ready() -> void:
	super._ready()
	_player = find_parent("Player")

func _while_idle(delta):
	if is_moving():
		_player.state_machine.send_event("walking")
	if not (is_hitting or is_working):
		_player.animation_player.play("Idle")

func _while_walking(delta):
	if not is_moving():
		_player.state_machine.send_event("idle")
	else:
		_player.change_direction()
		_player.animation_player.play("Walk")

func _while_running(delta):
	if not is_moving():
		_player.state_machine.send_event("idle")
	else:
		_player.change_direction()
		_player.animation_player.play("Run")

func _on_hitting() -> void:
	is_hitting = true
	_player.enable_movement(false)
	_player.state_machine.send_event("idle")
	_player.hit()

func _while_hitting(delta: float) -> void:
	_player.animation_player.play("Punch")
	
func _on_stop_hitting() -> void:
	is_hitting = false
	_player.enable_movement()

func _on_start_running():
	_player.cur_speed = _player.RUN_SPEED
	
func _on_stop_running():
	_player.cur_speed = _player.SPEED

func _while_jumping(delta: float) -> void:
	_player.animation_player.play("Jump")

func _on_item_picked() -> void:
	is_working = false
	_player.enable_movement()
	_player.pickup_item()

func _while_picking_up_an_item(delta: float) -> void:
	_player.animation_player.play("Working")

func _on_picking_up_an_item() -> void:
	is_working = true
	_player.enable_movement(false)
	_player.state_machine.send_event("idle")

func _on_start_chatting() -> void:
	is_chatting = true
	_player.enable_movement(false)
	_player.chat()
	

func _while_chatting(delta: float) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_stop_chatting() -> void:
	is_chatting = false
	_player.enable_movement()
	_player.end_conversation()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
