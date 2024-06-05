class_name Player extends RigidBody3D

var id

@onready var mesh : Node3D = %AnimatedHuman
@onready var tools_attatchment: BoneAttachment3D = $"AnimatedHuman/Human Armature/Skeleton3D/ToolsAttatchment"
@onready var monitor : Label = %Monitor
@onready var camera: Node3D = %Camera
@onready var floor_angle: RayCast3D = %FloorAngle
@onready var state_machine : PlayerStateMachine = %StateChart
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var controller: Controller = %Controller
@onready var ui: UI = $"../../UI"
@onready var jump_timer: Timer = %JumpTimer
@onready var floor_collider: Array[RayCast3D] = [$RayCast3D,$RayCast3D2,$RayCast3D3,$RayCast3D4,$RayCast3D5]
@onready var hit_area: Area3D = %HitArea

var mvmtKeysPressed : int = 0

var meshRotation : float
var input : Vector2

var inventory:Inventory = Inventory.new()
var hotbar:Inventory = Inventory.new()
var toolbar:Inventory = Inventory.new()

var equiped_tool : Pickup

# Tipo de dato correcto?
var pickable_objects:Array[PickupScene] = []
var npcs:Array[NPCScene] = []

signal in_area(item:Pickup)
signal not_in_area(item:Pickup)

var _should_move : bool = false
var can_jump : bool = true

var email : String

@export_category("Características")
@export var SPEED : float = 6.0
@export var RUN_MULTIPLIER : float = 1.7
@export var JUMP_VELOCITY : float = 25.0
@export var MAX_HEALTH : float = 100.0
@export var MAX_STAMINA : float = 100.0

var max_health : float = MAX_HEALTH
var max_stamina : float = MAX_STAMINA
var xp_needed : int = 100
var level_xp_multiplier : Callable = func (lvl): return pow(lvl, 1.5)

var cur_health : float = max_health
var cur_stamina : float = max_stamina
var money : int = 0
var xp : int = 0
var level : int = 0

var ground_dot_product : float = 0.77
var RUN_SPEED : float
var cur_speed : float = SPEED
var chatting_npc : NPCScene

var _pid := Pid3D.new(12 * mass, .001 * mass, 0.1 * mass)

func chat():
	if npcs.size() <= 0:
		return
	
	var npc_scene : NPCScene = npcs[0]
	var npc : NPC = npc_scene.npc
	
	if npc.dialogue == null:
		return
	
	npc_scene.talk(mesh)
	
	if npc.quest == null:
		DialogueManager.show_example_dialogue_balloon(npc.dialogue)
	else:
		if QuestSystem.is_quest_completed(npc.quest):
			DialogueManager.show_example_dialogue_balloon(npc.dialogue, "post_quest")
		elif QuestSystem.is_quest_active(npc.quest):
			DialogueManager.show_example_dialogue_balloon(npc.dialogue, "during_quest")
		else:
			DialogueManager.show_example_dialogue_balloon(npc.dialogue, "before_quest")

func _on_dialogue_end(dialogue:DialogueResource):
	change_state("not_interacting")

func _ready():
	RUN_SPEED = SPEED * RUN_MULTIPLIER
	hotbar.set_max_size(8)
	toolbar.set_max_size(3)
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	enable_movement()
	in_area.connect(ui._on_player_in_area)
	not_in_area.connect(ui._on_player_not_in_area)
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)
	
	MyQuestManager.player = self
	
	email = Server.player_email

func start_conversation():
	chatting_npc = npcs.filter(func (i): return i is NPCScene)[0]

func end_conversation():
	chatting_npc = null

func _physics_process(delta):
	if _should_move: move(delta)
	# DEBUG
	var tool : Array[Node] = tools_attatchment.get_children()
	if not tool.is_empty():
		tool[0].position = Vector3.ZERO
		tool[0].collision_layer = 0
		tool[0].collision_mask = 0
		
	monitor.set_monitor_values()

func move(delta):
	input = Input.get_vector("left", "right", "up", "down").normalized()
	var target_velocity = Vector3(input.x, 0, input.y) * cur_speed
	target_velocity = target_velocity.rotated(Vector3.UP, camera.get_rotation_y())
	var velocity_error = target_velocity - linear_velocity
	velocity_error.y = 0
	var correction_force = Vector3.ZERO
	if is_on_floor():
		var normal : Vector3 = floor_angle.get_collision_normal()
		velocity_error = velocity_error - normal * velocity_error.dot(normal)
		velocity_error *= max(ground_dot_product - normal.angle_to(Vector3.UP), 0.3)
		correction_force = _pid.update(velocity_error, delta)
		if Input.is_action_just_pressed("jump") and can_jump:
			apply_central_force(-get_gravity() * JUMP_VELOCITY * mass)
			jump_timer.start()
			can_jump = false
	else:
		if floor_angle.is_colliding() and floor_collider.any(func (i): return i.is_colliding()):
			var normal : Vector3 = floor_angle.get_collision_normal()
			if ground_dot_product < normal.angle_to(Vector3.UP) and not is_jumping():
				apply_central_force(get_gravity() * mass * 10)
		correction_force = _pid.update_jumping(velocity_error, delta)
		########ESTO AQUI O DESPUES DE IMPULSO
	if _should_move: apply_central_force(correction_force)
	if linear_velocity.length() < 0.1: linear_velocity = Vector3.ZERO

func change_direction():
	meshRotation = camera.get_rotation_y() + (PI if input.y > 0 else 0) + asin(-input.x) * sign(-input.y+0.5)
	mesh.rotation.y = lerp_angle(mesh.rotation.y, meshRotation, ease(0.5, -2))

func change_state(evnt:String) -> void:
	state_machine.send_event(evnt)

func is_on_floor() -> bool:
	return floor_collider.any(func (i): return i.is_colliding()) and floor_angle.is_colliding() and floor_angle.get_collision_normal().angle_to(Vector3.UP) < ground_dot_product

func enable_movement(enabled:bool = true) -> void:
	_should_move = enabled

func is_jumping():
	return !can_jump

#revisar
func pickup_item():
	var body : PickupScene = pickable_objects.pop_front()
	if body == null: return
	var item = body.item
	#pickup_item(body.item)
	body.queue_free()
	print("He pillado " + item.name)
	add_item(item, 1)
	
	#TODO
	#var next : PickupScene = pickable_objects.pop_front()
	#if next.item == body.item:
	#	pickup_item()
	
	enable_movement(true)

"""
func get_rotated_gravity() -> Vector3:
	if floor_collision.is_colliding():
		var normal : Vector3 = floor_collision.get_collision_normal()
		if normal.angle_to(Vector3.UP) < ground_dot_product:
			return normal * -1 * get_gravity()
		else:
			return get_gravity()
	else:
		return get_gravity()
"""

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	print(anim_name)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print(anim_name + " finished")

func hit():
	if hit_area.has_overlapping_areas():
		for i in hit_area.get_overlapping_areas():
			var enemy = i.get_parent().get_parent()
			if enemy.has_method("take_damage"):
				var damage : int = 1
				if tools_attatchment.get_child(0) != null:
					damage = equiped_tool.damage
				print(damage)
				enemy.take_damage(damage)

func equip_tool(tool:Pickup):
	equiped_tool = tool

func add_item(item:Pickup, qty:int):
	var node = ui.toolbar
	var index : int = -1
	var content = toolbar
	if item.is_tool():
		index = toolbar.add_item(item, 1)
	if index == -1:
		node = ui.hotbar
		content = hotbar
		index = hotbar.add_item(item, 1)
	if index == -1:
		node = ui._inventory
		content = inventory
		index = inventory.add_item(item, 1)
	if index == -1: return
	node.content.get_child(index).display(item, content.get_content()[index][1])
	ui._crafting.refresh_crafting()

# SOLO LLEGAMOS A REMOVE SI SABEMOS QUE LO TENEMOS
func remove_item(item:Pickup, qty:int):
	var response : Array = hotbar.remove_item(item, qty)
	# remain and index of removal
	if response[0] != 0:
		print("AQUI")
		if response[1] != -1:
			var slot : ItemSlot = ui.hotbar.content.get_child(response[1])
			slot.icon_container.remove_child(slot._item)
			slot._item = null
			slot.display(null)
		response = inventory.remove_item(item, response[0])
		var slot : ItemSlot = ui._inventory.content.get_child(response[1])
		if inventory._content.has(response[1]):
			slot._item._qty = inventory._content[response[1]][1]
			slot.display(item, inventory.get_content()[response[1]][1])
		else:
			slot.icon_container.remove_child(slot._item)
			slot._item = null
			slot.display(null)
	else:
		print("AQUI")
		var slot : ItemSlot = ui.hotbar.content.get_child(response[1])
		if hotbar._content.has(response[1]):
			slot._item._qty = hotbar._content[response[1]][1]
			slot.display(item, hotbar.get_content()[response[1]][1])
		else:
			slot.icon_container.remove_child(slot._item)
			slot._item = null
			slot.display(null)

func has_all_items(items:Array[Pickup]):
	var hotbar_array = hotbar._content.values()
	var inventory_array = inventory._content.values()
	print(hotbar_array)
	var array : Array = hotbar_array + inventory_array
	var inventory_dict : Dictionary = array_of_pairs_to_dict(array)
	# {item:qty,item:qty...}
	var items_dict : Dictionary = array_of_pairs_to_dict(items.map(func (i): return [i, 1]))
	
	for i in items_dict:
		if inventory_dict.keys().has(i):
			items_dict[i] -= inventory_dict[i]
	
	return items_dict.values().filter(func (i): return i > 0).is_empty()

func array_of_pairs_to_dict(array:Array) -> Dictionary:
	var result : Dictionary
	for i in array:
		if result.has(i[0]):
			result[i[0]] += i[1]
		else:
			result[i[0]] = i[1]
	return result

func _on_jump_timer_timeout() -> void:
	can_jump = true

func savedata(data:Dictionary) -> Dictionary:
	print("Player save function")
	if not data.keys().has("Players"):
		data["Players"] = {}
	data["Players"]["mail"] = email
	# Ahora mismo, solo un archivo por jugador, identificado con su correo
	if not data.keys().has("SaveFiles"):
		data["SaveFiles"] = {}
	data["SaveFiles"]["name"] = email
	data["SaveFiles"]["date"] = Time.get_datetime_string_from_system(true)
	data["SaveFiles"]["money"] = money
	data["SaveFiles"]["exp"] = xp
	data["SaveFiles"]["level"] = level
	data["SaveFiles"]["health"] = cur_health
	data["SaveFiles"]["max_health"] = max_health
	data["SaveFiles"]["max_stamina"] = max_stamina
	data["SaveFiles"]["inventory"] = var_to_bytes_with_objects(get_player_full_inventory())
	return data

func loaddata(data:Dictionary) -> Dictionary:
	email = data["Players"]["mail"]
	# Ahora mismo, solo un archivo de guardado por jugador, identificado con su correo ("name temporal")
	#email = data["SaveFiles"]["name"]		#OMITIMOS NOMBRE DEL ARCHIVO DE GUARDADO
	#OMITIMOS LA HORA Y FECHA
	money = data["SaveFiles"]["money"]
	xp = data["SaveFiles"]["exp"]
	level = int(data["SaveFiles"]["level"])
	cur_health = data["SaveFiles"]["health"]
	max_health = data["SaveFiles"]["max_health"]
	max_stamina = data["SaveFiles"]["max_stamina"]
	if data["SaveFiles"].keys().has("inventory") and data["SaveFiles"]["inventory"] != null:
		set_player_full_inventory(bytes_to_var_with_objects(data["SaveFiles"]["inventory"]))
		print(inventory)
		print(hotbar)
		print(toolbar)
	return data

func get_player_full_inventory() -> Dictionary:
	var data : Dictionary = {}
	data["inventory"] = inventory.get_content()
	data["hotbar"] = hotbar.get_content()
	data["toolbar"] = toolbar.get_content()
	return data

func set_player_full_inventory(data:Dictionary) -> void:
	#var changes : bool = inventory._content != data["inventory"] || hotbar._content != data["hotbar"] || toolbar._content != data["toolbar"]
	inventory._content = data["inventory"]
	hotbar._content = data["hotbar"]
	toolbar._content = data["toolbar"]
	#if changes:
	ui._ready()
	
	"""
	inventory.remove_all()
	for i in data["inventory"]:
		var slot : int = i
		var item : Pickup = data["inventory"][i][0]
		var qty : int = data["inventory"][i][1]
		inventory.store_item(item, qty, slot)
	
	hotbar.remove_all()
	for i in data["hotbar"]:
		var slot : int = i
		var item : Pickup = data["hotbar"][i][0]
		var qty : int = data["hotbar"][i][1]
		hotbar.store_item(item, qty, slot)
	
	toolbar.remove_all()
	for i in data["toolbar"]:
		var slot : int = i
		var item : Pickup = data["toolbar"][i][0]
		var qty : int = data["toolbar"][i][1]
		toolbar.store_item(item, qty, slot)
	"""
