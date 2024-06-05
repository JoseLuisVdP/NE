class_name CONVERSATION_MANAGER extends Node

var cur_talker : NPCScene

func end_chat():
	cur_talker.stop_talking()
	cur_talker = null
