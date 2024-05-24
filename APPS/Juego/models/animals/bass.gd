extends Node3D

var path_follow : PathFollow3D

func _ready() -> void:
	if path_follow != null:
		path_follow.progress_ratio = randf()
		print("Progress: " + str(path_follow.progress))

# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	$AnimationPlayer.play("Armature|Armature|ArmatureAction")
	if path_follow != null:
		path_follow.progress += 0.2
		position = path_follow.position
		rotation = path_follow.rotation + Vector3(0,-PI/2,0)
