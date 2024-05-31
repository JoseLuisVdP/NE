class_name SOUND_MANAGER extends Node

var sounds_rg : ResourceGroup
var sounds_array : Array[AudioStream]

var sounds : Dictionary

func load_sounds() -> void:
	assign_sound(&"ui_btn_click", sounds_array[0])
	assign_sound(&"ui_btn_hover", sounds_array[1])
	
	print(sounds_array)
	
	install_sounds(get_node("/root"))


func assign_sound(name:StringName, audio:AudioStream):
	sounds[name] = AudioStreamPlayer.new()
	sounds[name].stream = audio
	sounds[name].bus = &"UI"
	add_child(sounds[name])


func install_sounds(node:Node):
	for i in node.get_children():
		if i is Button:
			i.mouse_entered.connect(ui_sfx_play.bind(&"ui_btn_hover"))
			i.pressed.connect(ui_sfx_play.bind(&"ui_btn_click"))
		install_sounds(i)


func ui_sfx_play(sound:StringName):
	sounds[sound].play()