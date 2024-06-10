class_name MyIsland extends StaticBody3D

@onready var icosphere: MeshInstance3D = $Icosphere
@onready var forest: ProceduralForest = $Forest
@onready var grass: ProceduralGrass = $Grass
@onready var bass_paths: Node3D = %BassPaths
@onready var general_grass: ProceduralGrass = %GeneralGrass
@onready var mushrooms: ProceduralForest = $Mushrooms
@onready var suspicious_mushrooms: ProceduralForest = $SuspiciousMushrooms

@export var bass_scene : PackedScene
@export var enemy_scene : PackedScene
@export var bass_properties : Enemy

@onready var npc_11: NPCScene = $NPCs/NPC11
@onready var npc_12: NPCScene = $NPCs/NPC12


var mdt : MeshDataTool

func generate():
	add_bass()
	Scenes.update_loading_sreen_title("Generando bosques...")
	Scenes.update_loading_sreen_progress(0.1)
	await get_tree().process_frame
	await forest.generate()
	await mushrooms.generate()
	await suspicious_mushrooms.generate()
	Scenes.update_loading_sreen_title("Generando detalles...")
	Scenes.update_loading_sreen_progress(0.5)
	await get_tree().process_frame
	await grass.generate()
	Scenes.update_loading_sreen_title("Unos retoques finales...")	
	Scenes.update_loading_sreen_progress(0.7)
	await get_tree().process_frame
	await general_grass.generate()
	Scenes.update_loading_sreen_title("¡Listo!")
	Scenes.update_loading_sreen_progress(1)
	await get_tree().create_timer(1).timeout
	for i in $NPCs.get_children():
		i.inicializar()
	MyQuestManager.children.append(npc_11)
	MyQuestManager.children.append(npc_12)

func add_bass():
	for i in bass_paths.get_children():
		for j in i.get_children():
			var enemy_inst : EnemyScene = enemy_scene.instantiate()
			enemy_inst.scene = bass_scene
			add_child(enemy_inst)
			enemy_inst.instance_properties = bass_properties
			enemy_inst.get_child(0).path_follow = j
			enemy_inst.get_child(0)._ready()
			await get_tree().process_frame

"""
# Called when the node enters the scene tree for the first time.
func __ready() -> void:
	var prev_vertex = Vector3.ZERO
	var arr_size = mdt.get_vertex_count()
	var arr : Array = range(arr_size).map(func (i): return mdt.get_vertex(i))
	print(arr)
	var vertices : Dictionary = {}
	for i in range(arr_size):
		vertices[arr[i]] = 0
	print(vertices)
	for i in vertices.keys():
		var vert = i
		print(i)
		if prev_vertex == vert:
			continue
		var inst : EnemyScene = enemy_scene.instantiate()
		inst.instance_properties = instance_properties.duplicate()
		inst.scene = tree_scene
		inst.global_position = vert
		inst.rotation = Vector3.ZERO
		add_child(inst)
		prev_vertex = vert
	
	for i in range(1000000):
		pass
"""
