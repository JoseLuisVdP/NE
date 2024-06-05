class_name ProceduralGenerator extends Marker3D

@export var mesh_instance: MeshInstance3D
@export var radius : int = 150
@export var generation_density : float
var density : float
@export var auto_generate : bool = false
@export var max_angle : float = -1


func _ready():
	density = generation_density
	if auto_generate:
		generate()


func generate():
	pass

func generate_in_real_time():
	pass

func get_valid_verts(mesh:Mesh):
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
		if is_inside_radius(apos, bpos, cpos) && is_not_slope(apos, bpos, cpos):
			verts.append([apos,bpos,cpos])
	return verts


func is_inside_radius(apos : Vector3, bpos : Vector3, cpos : Vector3) -> bool:
	return apos.distance_to(position) <= radius || bpos.distance_to(position) <= radius || cpos.distance_to(position) <= radius


func is_not_slope(apos : Vector3, bpos : Vector3, cpos : Vector3) -> bool:
	if max_angle == -1:
		return true
	#Obtenemos dos puntos del plano, y con ellos la normal del mismo
	var x : Vector3 = bpos - apos
	var y : Vector3 = cpos - apos
	var n : Vector3 = x.cross(y).normalized() * -1
	
	# Devolvemos si la normal no supera el ángulo permitido
	return abs(rad_to_deg(n.angle_to(Vector3.UP))) < max_angle


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
	return int(density / 50 * area)
