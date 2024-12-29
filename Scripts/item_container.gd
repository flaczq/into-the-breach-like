extends Node

class_name ItemContainer

var id: int


func init(item_object: ItemObject, on_mouse_entered: Callable, on_mouse_exited: Callable, on_toggled: Callable) -> void:
	id = item_object.id
	assert(id >= 0, 'Wrong item id')
	
	name = name.replace('X', str(id))
	
	var cost_label = find_child('CostLabel') as Label
	cost_label.text = str(item_object.cost) + '$'
	
	var item_texture_button = find_child('ItemTextureButton')
	if on_mouse_entered.is_valid():
		item_texture_button.connect('mouse_entered', on_mouse_entered.bind(id))
	if on_mouse_exited.is_valid():
		item_texture_button.connect('mouse_exited', on_mouse_exited.bind(id))
	if on_toggled.is_valid():
		item_texture_button.connect('toggled', on_toggled.bind(id))
	item_texture_button.texture_normal = item_object.texture
	
	var name_label = find_child('NameLabel') as Label
	name_label.text = item_object.item_name
