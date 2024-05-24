class_name MyIsland extends StaticBody3D

@onready var icosphere: MeshInstance3D = $Icosphere
@onready var forest: Marker3D = $Forest
@onready var grass: ProceduralGrass = $Grass
@onready var bass_paths: Node3D = %BassPaths

@export var bass_scene : PackedScene
@export var grass_model : ArrayMesh
@export var enemy_scene : PackedScene
@export var bass_properties : Enemy

var mdt : MeshDataTool

func generate():
	add_bass()
	forest.add_forest()
	grass.add_grass()

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
