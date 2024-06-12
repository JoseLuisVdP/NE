class_name Inventory

# slot_index: [pickup, qty]
var _content:Dictionary = {}
var _max_size : int = 48
var active_slot : int = -1
var ui : UI

func add_item(item:Pickup, qty:int) -> int:
	if item.stack_size > 1:
		for i in _content:
			if _content[i][0].name == item.name:
				var result = _content[i][1] + qty -  _content[i][0].stack_size
				if result <= 0:
					_content[i][1] += qty
					return i
				else:
					_content[i][1] = _content[i][0].stack_size
					qty = result
	
	for i in range(_max_size):
		if not _content.has(i):
			_content[i] = [item, qty]
			return i
	return -1
	# Si llega aquí es porque esta lleno, asi que drop_item()?

func store_item(item:Pickup, qty:int, slot:int):
	if not _content.has(slot):
		_content[slot] = [item, qty]
	elif _content[slot][0].name == item.name:
		var result : int = _content[slot][1] + qty - _content[slot][0].stack_size
		if result <= 0:
			_content[slot][1] += qty
		else:
			_content[slot][1] = _content[slot][0].stack_size
			add_item(item, result)

func remove_item(item:Pickup, qty:int) -> Array:
	var remain : int = qty
	var index : int = -1
	for i in _content:
		if _content[i][0].name == item.name:
			if _content[i][1] - qty >= 0:
				remain = 0
				_content[i][1] -= qty
			else:
				remain -= _content[i][1]
				_content[i][1] = 0
			if _content[i][1] == 0: delete_item(i)
			index = i
			break
	return [remain, index]
	
func delete_item(slot:int):
	_content.erase(slot)

func get_content() -> Dictionary:
	return _content

func get_max_size() -> int:
	return _max_size

func set_max_size(size:int) -> void:
	_max_size = size

func merge_items():
	return null

func remove_all():
	_content = {}
