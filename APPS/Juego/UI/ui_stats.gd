class_name UIStats extends Control

var game : GAME
@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar

func _ready() -> void:
	game = find_parent("Game")
	var player = game.find_child("Player")
	health_bar.max_value = player.max_health
	stamina_bar.max_value = player.max_stamina
	health_bar.value = health_bar.max_value
	stamina_bar.value = stamina_bar.max_value

func add_health(qty:float) -> void:
	add(qty, health_bar)

func add_stamina(qty:float) -> void:
	add(qty, stamina_bar)

func add(qty:float, bar:ProgressBar) -> void:
	bar.value += qty
	if bar.value < 0:
		bar.value = 0
	elif bar.value > bar.max_value:
		bar.value = bar.max_value
