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
@onready var action_tooltip: ActionTooltip = $TextureRect/ActionsTextureButton/ActionTooltipX

var player: Player
var clicked_item_id: Util.ItemType = Util.ItemType.NONE
var is_action_tooltip_clicked: bool = false


func init(new_player: Player) -> void:
	#texture_rect.scale = Vector2(0.75, 0.75)
	
	player = new_player
	name = name.replace('X', str(player.id))
	
	assert(player.textures.size() == 3, 'Wrong player textures size')
	avatar_texture_button.texture_normal = player.textures[0]
	avatar_texture_button.texture_pressed = player.textures[1]
	avatar_texture_button.texture_hover = player.textures[2]
	
	update_stats()
	
	action_tooltip.init(player)


func update_stats() -> void:
	update_health()
	update_move_distance()
	update_items()


func update_health() -> void:
	var health = player.max_health
	if player.item_1.id == Util.ItemType.HEALTH:
		health += 1
	if player.item_2.id == Util.ItemType.HEALTH:
		health += 1
	health_label.text = str(health)


func update_move_distance() -> void:
	var move_distance = player.move_distance
	if player.item_1.id == Util.ItemType.MOVE_DISTANCE:
		move_distance += 1
	if player.item_2.id == Util.ItemType.MOVE_DISTANCE:
		move_distance += 1
	move_distance_label.text = str(move_distance)


func update_items() -> void:
	if player.item_1 and player.item_1.id != Util.ItemType.NONE:
		assert(player.item_1.textures.size() == 3, 'Wrong item 1 textures size')
		item_1_texture_button.texture_normal = player.item_1.textures[0]
		item_1_texture_button.texture_pressed = player.item_1.textures[1]
		item_1_texture_button.texture_hover = player.item_1.textures[2]
		item_1_texture_button.tooltip_text = player.item_1.description
	else:
		item_1_texture_button.texture_normal = null
		item_1_texture_button.texture_pressed = null
		item_1_texture_button.texture_hover = null
		item_1_texture_button.tooltip_text = 'no item\navailable\nfor you'
	
	if player.item_2 and player.item_2.id != Util.ItemType.NONE:
		assert(player.item_2.textures.size() == 3, 'Wrong item 2 textures size')
		item_2_texture_button.texture_normal = player.item_2.textures[0]
		item_2_texture_button.texture_pressed = player.item_2.textures[1]
		item_2_texture_button.texture_hover = player.item_2.textures[2]
		item_2_texture_button.tooltip_text = player.item_2.description
	else:
		item_2_texture_button.texture_normal = null
		item_2_texture_button.texture_pressed = null
		item_2_texture_button.texture_hover = null
		item_2_texture_button.tooltip_text = 'no item\navailable\nfor you'


func remove_item(item_id: Util.ItemType) -> void:
	if player.item_1.id == item_id:
		item_1_texture_button.texture_normal = null
		item_1_texture_button.texture_pressed = null
		item_1_texture_button.texture_hover = null
		item_1_texture_button.tooltip_text = 'no item\navailable\nfor you'
	elif player.item_2.id == item_id:
		item_2_texture_button.texture_normal = null
		item_2_texture_button.texture_pressed = null
		item_2_texture_button.texture_hover = null
		item_2_texture_button.tooltip_text = 'no item'


func move_item(item_id: Util.ItemType, target_item_texture_index: int) -> void:
	#var item = Util.get_selected_item(item_id)
	if item_id != Util.ItemType.NONE:
		remove_item(item_id)
	
	var temp_item_1 = player.item_1
	player.item_1 = player.item_2
	player.item_2 = temp_item_1
	update_items()


func reset_items(unclick_item_id: bool = true) -> void:
	item_1_texture_button.set_pressed_no_signal(false)
	item_2_texture_button.set_pressed_no_signal(false)
	if unclick_item_id:
		clicked_item_id = Util.ItemType.NONE


func _on_avatar_texture_button_mouse_entered() -> void:
	player_inventory_mouse_entered.emit(player.id)


func _on_avatar_texture_button_mouse_exited() -> void:
	player_inventory_mouse_exited.emit(player.id)


func _on_avatar_texture_button_toggled(toggled_on: bool) -> void:
	player_inventory_toggled.emit(toggled_on, player.id)


func _on_item_texture_button_pressed(item_texture_index: int) -> void:
	var new_clicked_item_id
	if item_texture_index == 0:
		new_clicked_item_id = player.item_1.id
	elif item_texture_index == 1:
		new_clicked_item_id = player.item_2.id
	
	# clicked empty inventory item when nothing was clicked before
	if clicked_item_id != Util.ItemType.NONE or new_clicked_item_id != Util.ItemType.NONE:
		item_1_texture_button.set_pressed_no_signal(false)
		item_2_texture_button.set_pressed_no_signal(false)
		
		if clicked_item_id != Util.ItemType.NONE and clicked_item_id == new_clicked_item_id:
			# unclick item
			clicked_item_id = Util.ItemType.NONE
		else:
			if new_clicked_item_id == Util.ItemType.NONE:
				pass
				#move_item(clicked_item_id, item_texture_index)
				#clicked_item_id = Util.ItemType.NONE
			else:
				if item_texture_index == 0:
					item_1_texture_button.set_pressed_no_signal(true)
				elif item_texture_index == 1:
					item_2_texture_button.set_pressed_no_signal(true)
				clicked_item_id = new_clicked_item_id
	
	item_clicked.emit(item_texture_index, clicked_item_id, player.id)


func _on_actions_texture_button_mouse_entered():
	for other_action_tooltip in get_parent().find_children('ActionTooltip?', 'ActionTooltip').filter(func(action_tooltip): return action_tooltip.player.id != player.id):
		other_action_tooltip.get_parent().set_pressed_no_signal(false)
		other_action_tooltip.hide()
	
	is_action_tooltip_clicked = false
	# hardcoded
	var action_tooltip_position
	if get_viewport().get_size().x - actions_texture_button.get_global_mouse_position().x < 450:
		action_tooltip_position = Vector2(-300, 10)
	else:
		action_tooltip_position = Vector2(10, 10)
	action_tooltip.set_position(actions_texture_button.get_global_mouse_position() + action_tooltip_position)
	action_tooltip.show()


func _on_actions_texture_button_mouse_exited():
	if not is_action_tooltip_clicked:
		actions_texture_button.set_pressed_no_signal(false)
		action_tooltip.hide()


func _on_actions_texture_button_toggled(toggled_on: bool) -> void:
	is_action_tooltip_clicked = toggled_on
	if is_action_tooltip_clicked:
		action_tooltip.show()
	else:
		action_tooltip.hide()
