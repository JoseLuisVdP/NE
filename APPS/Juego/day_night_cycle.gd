extends Node

var seconds : int = 0
var mins : int = 0
var hours : int = 0
var days : int = 0

@export var TIME_MULTIPLIER : float = 100

@onready var sunlight: DirectionalLight3D = $"../3D/Lights/Sunlight"
@onready var moonlight: DirectionalLight3D = $"../3D/Lights/Moonlight"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	seconds += delta * TIME_MULTIPLIER
	if seconds >= 60:
		seconds -= 60
		mins+=1
	if mins >= 60:
		mins -= 60
		hours += 1
	if hours >= 24:
		hours -= 24
		days += 1
	
