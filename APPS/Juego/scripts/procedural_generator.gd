class_name ProceduralGenerator extends Marker3D

@export var radius : int = 150
@export var density : float = 1

func get_valid_verts(mesh:ArrayMesh):
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh,0)
	var verts : Array = []
	for i in mdt.get_face_count():
		# Get the index in the vertex array.
		var a = mdt.get_face_vertex(i, 0)
		var b = mdt.get_face_vertex(i, 1)
		var c = mdt.get_face_vertex(i, 2)
		# Get vertex position using vertex index.
		var apos = mdt.get_vertex(a)
		var bpos = mdt.get_vertex(b)
		var cpos = mdt.get_vertex(c)
		verts.append([apos,bpos,cpos])
	return verts

func get_random_point_inside(vertices:Array) -> Vector3:
	var a
	var b
	a = randf_range(0.0,1.0)
	b = randf_range(0.0,1.0)
	if a > b:
		var temp = a
		a = b
		b = temp
	return vertices[0] * a + vertices[1] * (b - a) + vertices[2] * (1.0 - b)

func get_tri_area(tri:Array) -> float:
	var res : float
	var a : Vector3 = tri[0]
	var b : Vector3 = tri[1]
	var c : Vector3 = tri[2]
	var vec1 : Vector3 = b - a
	var vec2 : Vector3 = c - a
	var cross_prod : Vector3 = vec1.cross(vec2)
	res = sqrt(
		pow(cross_prod.x, 2) +
		pow(cross_prod.y, 2) +
		pow(cross_prod.z, 2)
	) / 2
	return res

func get_real_density(tri:Array, density:float) -> int:
	var area : float = get_tri_area(tri)
	return int(density * area)
