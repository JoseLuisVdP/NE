extends StaticBody3D

var path_follow : PathFollow3D
var parent : EnemyScene
var is_dying : bool = false

func _ready() -> void:
	if path_follow != null:
		path_follow.progress_ratio = randf()
		print("Progress: " + str(path_follow.progress))
	parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	if not is_dying:
		$AnimationPlayer.play("Armature|Armature|ArmatureAction")
		if path_follow != null:
			path_follow.progress += parent.instance_properties.velocity_points
			parent.position = path_follow.position
			parent.rotation = path_follow.rotation + Vector3(0,-PI/2,0)

func die():
	is_dying = true
