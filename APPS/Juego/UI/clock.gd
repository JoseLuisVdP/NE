extends Control


@onready var label: Label = $MarginContainer/Label


# Called when the node enters the scene tree for the first time.
func set_time(time:int):
	var h := str(int(time / 3600))
	if h.length() == 1:
		h = "0"+h
	
	var m := str(int(time % 3600 / 60))
	if m.length() == 1:
		m = "0"+m
	
	label.text = h + ":" + m
