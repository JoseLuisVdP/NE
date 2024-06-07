class_name ManNPC extends CharacterBody3D


@export var colors : Array[Material]
var skin_id : int = -1

@onready var animated_human: Node3D = $AnimatedHuman


"""
const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
"""


func _ready() -> void:
	if skin_id == -1:
		skin_id = randi_range(0, colors.size() - 1)
	%Human_Mesh.material_override = colors[skin_id]


func loaddata(data:Dictionary) -> Dictionary:
	if data["SaveFiles"].keys().has("NPCs"):
		if data["SaveFiles"]["NPCs"] == null or data["SaveFiles"]["NPCs"].is_empty():
			return data
		
		if not data["SaveFiles"]["NPCs"].keys().has(str(get_path())):
			return data
			
		skin_id = int(data["SaveFiles"]["NPCs"][str(get_path())])
		_ready()
	
	return data


func savedata(data:Dictionary) -> Dictionary:
	if not data["SaveFiles"].keys().has("NPCs") or data["SaveFiles"]["NPCs"] == null:
		data["SaveFiles"]["NPCs"] = {}
	
	data["SaveFiles"]["NPCs"][str(get_path())] = skin_id
	return data


func play_animation(animation:String):
	%AnimationPlayer.play(animation)
