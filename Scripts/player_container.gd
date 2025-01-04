extends Node

class_name PlayerContainer

signal item_clicked(player_item_id: int, item_id: Util.ItemType)

var empty_item_texture: CompressedTexture2D = preload('res://Assets/penzilla.vector-icon-pack/Icon_SquareStraight.png')

var id: int
var items_ids: Array[Util.ItemType] = [Util.ItemType.NONE, Util.ItemType.NONE]


func init(new_id: int, new_texture: CompressedTexture2D, on_toggled: Callable = Callable(), on_mouse_entered: Callable = Callable(), on_mouse_exited: Callable = Callable()) -> void:
	id = new_id
	assert(id >= 0, 'Wrong player object id')
	
	name = name.replace('X', str(id))
	
	# hide all children by default
	for child in get_children():
		child.hide()
	
	# find_child is required instead of @onready var because of weird 'scene inheritance'
	var player_texture_button = find_child('PlayerTextureButton') as TextureButton
	if on_toggled.is_valid():
		player_texture_button.connect('toggled', on_toggled.bind(id))
	if on_mouse_entered.is_valid():
		player_texture_button.connect('mouse_entered', on_mouse_entered.bind(id))
	if on_mouse_exited.is_valid():
		player_texture_button.connect('mouse_exited', on_mouse_exited.bind(id))
	player_texture_button.texture_normal = new_texture
	player_texture_button.show()
	
	var items_container = find_child('ItemsHBoxContainer') as HBoxContainer
	var player_item_1_texture_button = items_container.find_child('PlayerItem1TextureButton') as TextureButton
	player_item_1_texture_button.connect('pressed', _on_item_texture_button_pressed.bind(1))
	var player_item_2_texture_button = items_container.find_child('PlayerItem2TextureButton') as TextureButton
	player_item_2_texture_button.connect('pressed', _on_item_texture_button_pressed.bind(2))


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
	var inventory_item_1_texture_button = items_container.find_child('PlayerItem1TextureButton') as TextureButton
	if item_objects.size() > 0:
		inventory_item_1_texture_button.texture_normal = item_objects[0].texture
		inventory_item_1_texture_button.modulate.a = 1.0
		items_ids[0] = item_objects[0].id
	else:
		inventory_item_1_texture_button.texture_normal = empty_item_texture
		inventory_item_1_texture_button.modulate.a = 0.5
	
	var inventory_item_2_texture_button = items_container.find_child('PlayerItem2TextureButton') as TextureButton
	if item_objects.size() > 1:
		inventory_item_2_texture_button.texture_normal = item_objects[1].texture
		inventory_item_2_texture_button.modulate.a = 1.0
		items_ids[1] = item_objects[1].id
	else:
		inventory_item_2_texture_button.texture_normal = empty_item_texture
		inventory_item_2_texture_button.modulate.a = 0.5
	
	items_container.show()


func toggle_empty_items(is_toggled: bool) -> void:
	var items_container = find_child('ItemsHBoxContainer')
	var inventory_item_1_texture_button = items_container.find_child('PlayerItem1TextureButton') as TextureButton
	inventory_item_1_texture_button.modulate.a = (1.0) if (is_toggled) else (0.5)
	var inventory_item_2_texture_button = items_container.find_child('PlayerItem2TextureButton') as TextureButton
	inventory_item_2_texture_button.modulate.a = (1.0) if (is_toggled) else (0.5)


func _on_item_texture_button_pressed(player_item_id: int) -> void:
	var item_id = items_ids[player_item_id - 1]
	item_clicked.emit(player_item_id, item_id)
