@tool
extends StaticBody3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$MillPart_02.rotation.z += 0.01
