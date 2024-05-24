@tool
class_name EnemyScene extends Node3D

@export var instance_properties:Enemy
@export var scene : PackedScene
@export var item_scene : PackedScene

var game : GAME
var animation_player : AnimationPlayer

func _ready() -> void:
	game = find_parent("Game")
	var enemy = scene.instantiate()
	add_child(enemy)
	animation_player = enemy.find_child("AnimationPlayer")
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)

func take_damage(dmg:int):
	instance_properties.live_points -= dmg
	if instance_properties.live_points <= 0:
		die()

func die():
	animation_player.play("fall")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	call_deferred("drop_items")
	get_parent().call_deferred("remove_child", self)
	queue_free()

func drop_items():
	var acc : float = 0
	for i in instance_properties.drops:
		acc += 0.2
		var pickup = item_scene.instantiate()
		pickup.item = i
		game.add_child(pickup)
		pickup.global_position = global_position + Vector3.UP * (2+acc)
