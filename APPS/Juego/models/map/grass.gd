class_name ProceduralGrass extends ProceduralGenerator

@export var meshes : Array[Mesh]
@export var grass_material : Material
@export var margin : int = 50
@export var hole : int = -1
@export var noise : NoiseTexture2D
@export var noise_scale : float = 0


func generate() -> void:
	var tris : Array = get_valid_verts(mesh_instance.mesh)
	await add_grass(tris)
	#add_grass_old(tri)
	
	
func generate_in_real_time() -> void:
	var tris : Array = get_valid_verts(mesh_instance.mesh)
	add_grass(tris)
	#add_grass_old(tri)


func add_grass(tris:Array):
	var pos : Array[Vector3] = calculate_grass_position(tris)
	
	var pos_divided : Array[Array] = []
	
	for i in range(meshes.size()):
		pos_divided.append([])
		if meshes.size() > 1:
			for e in range(pos.size()):
				pos_divided[i % meshes.size()].append(pos[i])
		else:
			pos_divided[0] = pos
		var multi : MultiMeshInstance3D = get_multimesh_3d(meshes[i], pos_divided[i].size(), grass_material)
		multi.layers = 2
		await allocate_grass(multi, pos_divided[i])

func get_multimesh_3d(mesh:ArrayMesh, count:int, material:Material) -> MultiMeshInstance3D:
	var multimesh_3d : MultiMeshInstance3D = MultiMeshInstance3D.new()
	
	multimesh_3d.multimesh = MultiMesh.new()
	multimesh_3d.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh_3d.multimesh.mesh = mesh
	multimesh_3d.multimesh.instance_count = count
	multimesh_3d.multimesh.visible_instance_count = count
	if material != null:
		multimesh_3d.multimesh.mesh.surface_set_material(0, material)
	add_child(multimesh_3d)
	
	return multimesh_3d

func allocate_grass(multi:MultiMeshInstance3D, position:Array) -> void:
	for i in range(multi.multimesh.instance_count):
		var pos = position[i]
		multi.multimesh.set_instance_transform(i, Transform3D().translated(pos))

func calculate_grass_position(tris:Array) -> Array[Vector3]:
	var points : Array[Vector3] = []
	var noise_image : Image = null
	if noise != null:
		noise_image = noise.get_image()
	else:
		noise_scale = 0
	for tri in tris:
		var real_density = get_real_density(tri, density)
		
		for i in range(real_density):
			var randpos = get_random_point_inside(tri) - position
			if randpos.distance_to(Vector3.ZERO) <= radius:
				if randpos.distance_to(Vector3.ZERO) > hole:
					var diff = radius - randpos.distance_to(Vector3.ZERO)
				
					# Cuan externo es
					var ext = diff/margin
					
					var noise_value : float = 1
					
					if noise_scale > 0:
						var texture_pos := Vector2(randpos.x, randpos.z) * noise_scale
						noise_value = noise_image.get_pixel(abs(int(texture_pos.x)) % noise_image.get_width(), abs(int(texture_pos.y)) % noise_image.get_height()).r
						ext += noise_value
					
					if diff <= margin:
						var r : float = randf()
						if r + 0.1 < ext:
							points.append(randpos)
					else:
						points.append(randpos)
	return points









"""
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
"""
