class_name ProceduralGrass extends ProceduralGenerator

@onready var icosphere: MeshInstance3D = $"../Icosphere"

@export var grass_mesh : Mesh
@export var grass_material : ShaderMaterial
@export var margin : int = 50

func add_grass() -> void:
	
	var tris : Array = get_valid_verts(icosphere.mesh)
	
	for tri in tris:
		var c = false
		for i in tri:
			if Vector3.ZERO.distance_to(i-position) > radius + margin:
				c = true
				continue
		if c:
			continue
		add_grass_old(tri)
		await get_tree().process_frame

func add_grass_wip(tris:Array):
	var pos : Array[Vector3] = calculate_grass_position(tris)
	
	var multi : MultiMeshInstance3D = get_multimesh_3d(grass_mesh, pos.size(), grass_material)
	
	allocate_grass(multi, pos)

func get_multimesh_3d(mesh:ArrayMesh, count:int, material:Material) -> MultiMeshInstance3D:
	var multimesh_3d : MultiMeshInstance3D = MultiMeshInstance3D.new()
	
	multimesh_3d.multimesh = MultiMesh.new()
	multimesh_3d.multimesh.mesh = mesh
	multimesh_3d.multimesh.instance_count = count
	multimesh_3d.multimesh.mesh.surface_set_material(0, material)
	
	return multimesh_3d

func allocate_grass(multi:MultiMeshInstance3D, position:Array[Vector3]) -> void:
	print(position.size())
	for i in range(multi.multimesh.instance_count):
		var pos = position[i]
		multi.multimesh.set_instance_transform(i, Transform3D().translated(pos))

	#add_child(multi)

func calculate_grass_position(tris:Array) -> Array[Vector3]:
	var points : Array[Vector3] = []
	for tri in tris:
		var real_density = get_real_density(tri, density)
		
		for i in range(real_density):
			var randpos = get_random_point_inside(tri) - position
			if randpos.distance_to(Vector3.ZERO) <= radius:
				pass
				#points.append(Transform3D().translated(randpos))
			points.append(randpos)
	return points

func add_grass_old(tri:Array) -> void:
	var area : float = get_tri_area(tri)
	var real_density : int = int(density * area)
	var multimesh_3d : MultiMeshInstance3D = MultiMeshInstance3D.new()
	multimesh_3d.multimesh = MultiMesh.new()
	multimesh_3d.multimesh.mesh = grass_mesh
	multimesh_3d.scale = Vector3.ONE * 0.1
	multimesh_3d.multimesh.instance_count = real_density
	multimesh_3d.multimesh.mesh.surface_set_material(0, grass_material)
	for i in real_density:
		var randpos = get_random_point_inside(tri) - position
		if randpos.distance_to(Vector3.ZERO) > radius + 50:
			pass
		else:
			multimesh_3d.multimesh.set_instance_transform(i, Transform3D().translated(randpos))
		
	
	for i in range(int(real_density)):
		var randpos = get_random_point_inside(tri) - position
		if randpos.distance_to(Vector3.ZERO) < radius:
			var mesh = MeshInstance3D.new()
			mesh.mesh = grass_mesh
			mesh.position = randpos
			add_child(mesh)