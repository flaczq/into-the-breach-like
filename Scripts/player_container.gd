extends Node

class_name PlayerContainer

var id: int
var item_ids: Array[int]


func init(new_id: int, new_texture: CompressedTexture2D, on_mouse_entered: Callable, on_mouse_exited: Callable, on_toggled: Callable) -> void:
	id = new_id
	assert(id >= 0, 'Wrong player object id')
	
	name = name.replace('X', str(id))
	
	# hide all children by default
	for child in get_children():
		child.hide()
	
	# find_child is required instead of @onready var because of weird 'scene inheritance'
	var player_texture_button = find_child('PlayerTextureButton') as TextureButton
	if on_mouse_entered.is_valid():
		player_texture_button.connect('mouse_entered', on_mouse_entered.bind(id))
	if on_mouse_exited.is_valid():
		player_texture_button.connect('mouse_exited', on_mouse_exited.bind(id))
	if on_toggled.is_valid():
		player_texture_button.connect('toggled', on_toggled.bind(id))
	player_texture_button.texture_normal = new_texture
	player_texture_button.show()


func init_stats(max_health: int, move_distance: int, damage: int, action_type: Util.ActionType) -> void:
	var health_container = find_child('HealthHBoxContainer')
	var health_label = health_container.find_child('HealthLabel') as Label
	health_label.text = str(max_health)
	health_container.show()
	
	var move_distance_container = find_child('MoveDistanceHBoxContainer')
	var move_distance_label = move_distance_container.find_child('MoveDistanceLabel') as Label
	move_distance_label.text = str(move_distance)
	move_distance_container.show()
	
	var damage_container = find_child('DamageHBoxContainer')
	var damage_label = damage_container.find_child('DamageLabel') as Label
	damage_label.text = str(damage)
	damage_container.show()
	
	var action_container = find_child('ActionHBoxContainer')
	var action_label = action_container.find_child('ActionLabel') as Label
	action_label.text = tr('ACTION_' + str(Util.ActionType.keys()[action_type]))
	action_container.show()


func init_items(item_objects: Array[ItemObject]) -> void:
	assert(item_objects.size() <= 2, 'Wrong item objects size')
	var items_container = find_child('ItemsHBoxContainer')
	if item_objects.size() > 0:
		var item_1 = items_container.find_child('Item1TextureRect') as TextureRect
		item_1.texture = item_objects[0].texture
		
		item_ids[0] = item_objects[0].id
	if item_objects.size() > 1:
		var item_2 = items_container.find_child('Item2TextureRect') as TextureRect
		item_2.texture = item_objects[1].texture
		
		item_ids[1] = item_objects[1].id
	
	items_container.show()
