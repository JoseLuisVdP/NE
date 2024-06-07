extends Control

@onready var progress_bar: ProgressBar = $ProgressBar


func set_temp(temp:float):
	progress_bar.indeterminate = false
	progress_bar.value = temp
