class_name UIStats extends Control

var game : GAME
@onready var health_bar: RadialProgress = %HealthBar
@onready var stamina_bar: RadialProgress = %StaminaBar
@onready var health: Label = %Health

func _ready() -> void:
	game = find_parent("Game")
	var player = game.find_child("Player")
	health_bar.max_value = player.max_health
	stamina_bar.max_value = player.max_stamina
	health_bar.progress = health_bar.max_value
	stamina_bar.progress = stamina_bar.max_value

func add_health(qty:float) -> void:
	add(qty, health_bar)
	if health_bar.progress < health_bar.max_value/2:
		health_bar.bar_color = Color.YELLOW
	elif health_bar.progress < health_bar.max_value/4:
		health_bar.bar_color = Color.RED
	health.text = str(health_bar.progress)
		
func add_stamina(qty:float) -> void:
	add(qty, stamina_bar)

func add(qty:float, bar:RadialProgress) -> void:
	bar.progress += qty
	if bar.progress < 0:
		bar.progress = 0
	elif bar.progress > bar.max_value:
		bar.progress = bar.max_value
