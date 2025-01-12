extends Node

class_name PlayerContainer

signal item_clicked(player_item_id: int, item_id: Util.ItemType, player_id: Util.PlayerType)

var empty_item_texture: CompressedTexture2D = preload('res://Assets/penzilla.vector-icon-pack/Icon_SquareStraight.png')

var player_items_texture_buttons: Array[TextureButton]
var id: Util.PlayerType

var items_ids: Array[Util.ItemType] = [Util.ItemType.NONE, Util.ItemType.NONE]
var clicked_item_id: Util.ItemType = Util.ItemType.NONE


func init(new_id: Util.PlayerType, new_texture: CompressedTexture2D, on_toggled: Callable = Callable(), on_mouse_entered: Callable = Callable(), on_mouse_exited: Callable = Callable()) -> void:
	id = new_id
	assert(id != Util.PlayerType.NONE, 'Wrong player object id')
	
	name = name.replace('X', str(id))
	
	var player_stats_v_box_container = find_child('PlayerStatsVBoxContainer') as VBoxContainer
	player_stats_v_box_container.hide()
	
	# find_child is required instead of @onready var because of weird 'scene inheritance'
	var player_texture_button = find_child('PlayerTextureButton') as TextureButton
	if on_toggled.is_valid():
		player_texture_button.connect('toggled', on_toggled.bind(id))
	if on_mouse_entered.is_valid():
		player_texture_button.connect('mouse_entered', on_mouse_entered.bind(id))
	if on_mouse_exited.is_valid():
		player_texture_button.connect('mouse_exited', on_mouse_exited.bind(id))
	player_texture_button.texture_normal = new_texture
	
	var items_container = find_child('ItemsHBoxContainer') as HBoxContainer
	var player_item_1_texture_button = items_container.find_child('PlayerItem1TextureButton') as TextureButton
	player_item_1_texture_button.connect('pressed', _on_item_texture_button_pressed.bind(1))
	var player_item_2_texture_button = items_container.find_child('PlayerItem2TextureButton') as TextureButton
	player_item_2_texture_button.connect('pressed', _on_item_texture_button_pressed.bind(2))
	items_container.hide()
	
	player_items_texture_buttons = [
		player_item_1_texture_button,
		player_item_2_texture_button
	]


func init_stats(max_health: int, move_distance: int, damage: int, action_type: Util.ActionType) -> void:
	var player_stats_v_box_container = find_child('PlayerStatsVBoxContainer') as VBoxContainer
	player_stats_v_box_container.show()
	
	var health_container = find_child('HealthHBoxContainer')
	var health_label = health_container.find_child('HealthLabel') as Label
	health_label.text = str(max_health)
	
	var move_distance_container = find_child('MoveDistanceHBoxContainer')
	var move_distance_label = move_distance_container.find_child('MoveDistanceLabel') as Label
	move_distance_label.text = str(move_distance)
	
	var damage_container = find_child('DamageHBoxContainer')
	var damage_label = damage_container.find_child('DamageLabel') as Label
	damage_label.text = str(damage)
	
	var action_container = find_child('ActionHBoxContainer')
	var action_label = action_container.find_child('ActionLabel') as Label
	action_label.text = tr('ACTION_' + str(Util.ActionType.keys()[action_type]))


func init_items(item_objects: Array[ItemObject]) -> void:
	assert(item_objects.size() == 2, 'Wrong item objects size')
	var items_container = find_child('ItemsHBoxContainer')
	items_container.show()
	
	var index = 0
	for item_object in item_objects:
		if item_object and item_object.id != Util.ItemType.NONE:
			player_items_texture_buttons[index].texture_normal = item_object.texture
			player_items_texture_buttons[index].modulate.a = 1.0
			items_ids[index] = item_object.id
		else:
			player_items_texture_buttons[index].texture_normal = empty_item_texture
			player_items_texture_buttons[index].modulate.a = 0.5
			items_ids[index] = Util.ItemType.NONE
		index += 1


func remove_item(item_id: Util.ItemType) -> void:
	var player_item_id = items_ids.find(item_id) + 1
	var texture_button = player_items_texture_buttons[player_item_id - 1]
	texture_button.texture_normal = empty_item_texture
	texture_button.modulate.a = 0.5
	items_ids[player_item_id - 1] = Util.ItemType.NONE


func move_item(item_id: Util.ItemType, target_player_item_id: int) -> void:
	#var item = Util.get_selected_item(item_id)
	if item_id != Util.ItemType.NONE:
		remove_item(item_id)
	
	assert(items_ids[target_player_item_id - 1] == Util.ItemType.NONE, 'Target player item not empty')
	items_ids[target_player_item_id - 1] = item_id
	
	var items = [] as Array[ItemObject]
	for current_item_id in items_ids:
		var current_item = Util.get_selected_item(current_item_id)
		items.push_back(current_item)
	init_items(items)


func reset_items(is_highlighted: bool = false, declick_item_id: bool = true) -> void:
	player_items_texture_buttons[0].modulate.a = (1.0) if (is_highlighted or items_ids[0] != Util.ItemType.NONE) else (0.5)
	player_items_texture_buttons[1].modulate.a = (1.0) if (is_highlighted or items_ids[1] != Util.ItemType.NONE) else (0.5)
	if declick_item_id:
		clicked_item_id = Util.ItemType.NONE


func _on_item_texture_button_pressed(player_item_id: int) -> void:
	var new_clicked_item_id = items_ids[player_item_id - 1]
	# clicked empty inventory item when nothing was clicked before
	if clicked_item_id != Util.ItemType.NONE or new_clicked_item_id != Util.ItemType.NONE:
		var index = 0
		for player_item_texture_button in player_items_texture_buttons:
			player_item_texture_button.set_pressed_no_signal(false)
			if items_ids[index] == Util.ItemType.NONE:
				# highlight empty inventory items to move clicked item to
				player_item_texture_button.modulate.a = (1.0) if (new_clicked_item_id != Util.ItemType.NONE and clicked_item_id != new_clicked_item_id) else (0.5)
			else:
				player_item_texture_button.modulate.a = 1.0
			index += 1
		
		var texture_button = player_items_texture_buttons[player_item_id - 1]
		if clicked_item_id != Util.ItemType.NONE and clicked_item_id == new_clicked_item_id:
			# declick item
			texture_button.modulate.a = 1.0
			clicked_item_id = Util.ItemType.NONE
		else:
			if new_clicked_item_id == Util.ItemType.NONE:
				move_item(clicked_item_id, player_item_id)
				clicked_item_id = Util.ItemType.NONE
			else:
				texture_button.set_pressed_no_signal(true)
				texture_button.modulate.a = 1.0
				clicked_item_id = new_clicked_item_id
	
	item_clicked.emit(player_item_id, clicked_item_id, id)
