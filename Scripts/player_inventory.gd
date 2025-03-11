extends Control

class_name PlayerInventory

signal player_inventory_mouse_entered(player_id: Util.PlayerType)
signal player_inventory_mouse_exited(player_id: Util.PlayerType)
signal player_inventory_toggled(toggled_on: bool, player_id: Util.PlayerType)
signal item_clicked(item_texture_index: int, item_id: Util.ItemType, player_id: Util.PlayerType)

@onready var texture_rect = $TextureRect
@onready var avatar_texture_button = $TextureRect/AvatarTextureButton
@onready var health_label = $TextureRect/HealthLabel
@onready var move_distance_label = $TextureRect/MoveDistanceLabel
@onready var item_1_texture_button = $TextureRect/ItemSlot1TextureButton/Item1TextureButton
@onready var item_2_texture_button = $TextureRect/ItemSlot2TextureButton/Item2TextureButton
@onready var actions_texture_button = $TextureRect/ActionsTextureButton
#@onready var action_1_texture_button = $TextureRect/Action1TextureButton
#@onready var action_2_texture_button = $TextureRect/Action2TextureButton

var id: Util.PlayerType
var items_ids: Array[Util.ItemType] = [Util.ItemType.NONE, Util.ItemType.NONE]
var clicked_item_id: Util.ItemType = Util.ItemType.NONE


func init(player_id: Util.PlayerType, player_textures: Array[CompressedTexture2D], action_1_textures: Array[CompressedTexture2D], action_2_textures: Array[CompressedTexture2D], player_max_health: int, player_move_distance: int, item_1: ItemObject = null, item_2: ItemObject = null) -> void:
	#texture_rect.scale = Vector2(0.75, 0.75)
	
	id = player_id
	name = name.replace('X', str(id))
	
	assert(player_textures.size() == 3, 'Wrong player textures size')
	avatar_texture_button.texture_normal = player_textures[0]
	avatar_texture_button.texture_pressed = player_textures[1]
	avatar_texture_button.texture_hover = player_textures[2]
	
	update_stats(player_max_health, player_move_distance)
	
	#assert(action_1_textures.size() == 3, 'Wrong action 1 textures size')
	#action_1_texture_button.texture_normal = action_1_textures[0]
	#action_1_texture_button.texture_pressed = action_1_textures[1]
	#action_1_texture_button.texture_hover = action_1_textures[2]
	#
	#assert(action_2_textures.size() == 3, 'Wrong action 2 textures size')
	#action_2_texture_button.texture_normal = action_2_textures[0]
	#action_2_texture_button.texture_pressed = action_2_textures[1]
	#action_2_texture_button.texture_hover = action_2_textures[2]
	
	init_items(item_1, item_2)


func update_health(player_max_health: int) -> void:
	health_label.text = str(player_max_health)


func update_move_distance(player_move_distance: int) -> void:
	move_distance_label.text = str(player_move_distance)


func update_stats(player_max_health: int, player_move_distance: int) -> void:
	update_health(player_max_health)
	update_move_distance(player_move_distance)


func init_items(item_1: ItemObject = null, item_2: ItemObject = null) -> void:
	if item_1 and item_1.id != Util.ItemType.NONE:
		assert(item_1.textures.size() == 3, 'Wrong item 1 textures size')
		item_1_texture_button.texture_normal = item_1.textures[0]
		item_1_texture_button.texture_pressed = item_1.textures[1]
		item_1_texture_button.texture_hover = item_1.textures[2]
		items_ids[0] = item_1.id
	else:
		item_1_texture_button.texture_normal = null
		item_1_texture_button.texture_pressed = null
		item_1_texture_button.texture_hover = null
		items_ids[0] = Util.ItemType.NONE
	
	if item_2 and item_2.id != Util.ItemType.NONE:
		assert(item_2.textures.size() == 3, 'Wrong item 2 textures size')
		item_2_texture_button.texture_normal = item_2.textures[0]
		item_2_texture_button.texture_pressed = item_2.textures[1]
		item_2_texture_button.texture_hover = item_2.textures[2]
		items_ids[1] = item_2.id
	else:
		item_2_texture_button.texture_normal = null
		item_2_texture_button.texture_pressed = null
		item_2_texture_button.texture_hover = null
		items_ids[1] = Util.ItemType.NONE


func remove_item(item_id: Util.ItemType) -> void:
	var item_texture_index = items_ids.find(item_id)
	assert(item_texture_index == 0 or item_texture_index == 1, 'Wrong item texture index')
	if item_texture_index == 0:
		item_1_texture_button.texture_normal = null
		item_1_texture_button.texture_pressed = null
		item_1_texture_button.texture_hover = null
	elif item_texture_index == 1:
		item_2_texture_button.texture_normal = null
		item_2_texture_button.texture_pressed = null
		item_2_texture_button.texture_hover = null
	items_ids[item_texture_index] = Util.ItemType.NONE


func move_item(item_id: Util.ItemType, target_item_texture_index: int) -> void:
	#var item = Util.get_selected_item(item_id)
	if item_id != Util.ItemType.NONE:
		remove_item(item_id)
	
	assert(target_item_texture_index == 0 or target_item_texture_index == 1, 'Wrong target item texture index')
	assert(items_ids[target_item_texture_index] == Util.ItemType.NONE, 'Target item is not empty')
	items_ids[target_item_texture_index] = item_id
	
	assert(items_ids.size() == 2, 'Wrong items size')
	var item_1 = Util.get_selected_item(items_ids[0])
	var item_2 = Util.get_selected_item(items_ids[1])
	init_items(item_1, item_2)


func reset_items(unclick_item_id: bool = true) -> void:
	item_1_texture_button.set_pressed_no_signal(false)
	item_2_texture_button.set_pressed_no_signal(false)
	if unclick_item_id:
		clicked_item_id = Util.ItemType.NONE


func _on_avatar_texture_button_mouse_entered() -> void:
	player_inventory_mouse_entered.emit(id)


func _on_avatar_texture_button_mouse_exited() -> void:
	player_inventory_mouse_exited.emit(id)


func _on_avatar_texture_button_toggled(toggled_on: bool) -> void:
	player_inventory_toggled.emit(toggled_on, id)


func _on_item_1_texture_button_pressed():
	var new_clicked_item_id = items_ids[0]
	# clicked empty inventory item when nothing was clicked before
	if clicked_item_id != Util.ItemType.NONE or new_clicked_item_id != Util.ItemType.NONE:
		item_1_texture_button.set_pressed_no_signal(false)
		item_2_texture_button.set_pressed_no_signal(false)
		#if items_ids[0] == Util.ItemType.NONE:
			## highlight empty inventory items to move clicked item to
			#item_1_texture_button.modulate.a = (1.0) if (new_clicked_item_id != Util.ItemType.NONE and clicked_item_id != new_clicked_item_id) else (0.5)
		#else:
			#item_1_texture_button.modulate.a = 1.0
		
		if clicked_item_id != Util.ItemType.NONE and clicked_item_id == new_clicked_item_id:
			# unclick item
			#item_1_texture_button.modulate.a = 1.0
			clicked_item_id = Util.ItemType.NONE
		else:
			if new_clicked_item_id == Util.ItemType.NONE:
				move_item(clicked_item_id, 0)
				clicked_item_id = Util.ItemType.NONE
			else:
				item_1_texture_button.set_pressed_no_signal(true)
				#item_1_texture_button.modulate.a = 1.0
				clicked_item_id = new_clicked_item_id
	
	item_clicked.emit(0, clicked_item_id, id)


func _on_item_2_texture_button_pressed():
	print('add to item 2')


func _on_actions_texture_button_mouse_entered():
	print('show popup with actions')
