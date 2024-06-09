
class_name PickupScene extends Node3D

@export var item:Pickup
@onready var despawn: Timer = $Despawn
var audio_stream_player: AudioStreamPlayer = null
@export var picked_up_audio : AudioStreamWAV

@export var should_despawn : bool = true

func _ready():
	if item != null:
		var instance = item.scene.instantiate()
		add_child(instance)
	else:
		print("null item" + str(get_instance_id()))
	var audio = find_child("AudioStreamPlayer")
	if audio != null:
		audio_stream_player = audio
		audio_stream_player.stream = picked_up_audio
		audio_stream_player.finished.connect(_on_despawn_timeout)


func _on_despawn_timeout() -> void:
	if should_despawn:
		queue_free()

func picked() -> void:
	if audio_stream_player != null:
		audio_stream_player.play()
	else:
		if should_despawn:
			queue_free()
