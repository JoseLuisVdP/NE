class_name ProceduralForest extends ProceduralGenerator

@onready var icosphere: MeshInstance3D = $"../Icosphere"

@export var instance_properties:Enemy
@export var enemy_scene : PackedScene
@export var tree_scene : PackedScene
@export var item_scene : PackedScene
@export var margin : int = 50

func generate() -> void:
	var tris : Array = get_valid_verts(icosphere.mesh)
	add_trees(tris)


func add_trees(tris:Array) -> void:
	for tri in tris:
		var c = false
		add_tree_batch(tri, get_real_density(tri, density))


func add_tree_batch(tri:Array, real_density:int) -> void:
	for i in range(real_density):
		var randpos = get_random_point_inside(tri) - position
		if randpos.distance_to(Vector3.ZERO) < radius:
			var inst : EnemyScene = enemy_scene.instantiate()
			inst.instance_properties = instance_properties.duplicate()
			inst.scene = tree_scene
			inst.item_scene = item_scene
			inst.position = randpos
			inst.rotation = Vector3.ZERO
			add_child(inst)
			await get_tree().process_frame
