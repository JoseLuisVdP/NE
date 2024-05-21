extends Node
## Groups all timers in one class so they can be called easily.
class_name Timers

@onready var fill_es_clima_api_timer : FillClimaAPITimer = %FillESClimaAPITimer
@onready var once_a_day: Timer = %OnceADay
@onready var server: Server = $".."

signal fill_es_clima_api_timer_timeout(date:String)

func _on_fill_es_clima_api_timer_timeout():
	fill_es_clima_api_timer_timeout.emit(fill_es_clima_api_timer.date)

func start_all():
	for i in get_children():
		i.start()
