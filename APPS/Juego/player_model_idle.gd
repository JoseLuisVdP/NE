extends Node3D

@export var animation : String

func _process(delta: float) -> void:
	%AnimationPlayer.play(animation)
