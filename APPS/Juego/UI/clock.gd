extends Control


@onready var time: Label = %Time
@onready var date: Label = %Date


# Called when the node enters the scene tree for the first time.
func set_time():
	var h := str(int(GlobalTime.day_time_formated / 3600))
	if h.length() == 1:
		h = "0"+h
	
	var m := str(int(GlobalTime.day_time_formated % 3600 / 60))
	if m.length() == 1:
		m = "0"+m
	
	time.text = h + ":" + m
	date.text = str(GlobalTime.cur_day) + "/" + str(GlobalTime.cur_month)
