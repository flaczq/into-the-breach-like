extends Node

class_name Shop

signal item_hovered(item_texture_index: int, item_id: Util.ItemType, is_hovered: bool)
signal item_clicked(item_texture_index: int, item_id: Util.ItemType)

@onready var shop_item_1_cost_label = $ShopItemsHBoxContainer/ShopItem1VBoxContainer/ShopItem1CostLabel
@onready var shop_item_1_texture_button = $ShopItemsHBoxContainer/ShopItem1VBoxContainer/ShopItem1TextureButton
@onready var shop_item_1_name_label = $ShopItemsHBoxContainer/ShopItem1VBoxContainer/ShopItem1NameLabel
@onready var shop_item_2_cost_label = $ShopItemsHBoxContainer/ShopItem2VBoxContainer/ShopItem2CostLabel
@onready var shop_item_2_texture_button = $ShopItemsHBoxContainer/ShopItem2VBoxContainer/ShopItem2TextureButton
@onready var shop_item_2_name_label = $ShopItemsHBoxContainer/ShopItem2VBoxContainer/ShopItem2NameLabel
@onready var shop_item_3_cost_label = $ShopItemsHBoxContainer/ShopItem3VBoxContainer/ShopItem3CostLabel
@onready var shop_item_3_texture_button = $ShopItemsHBoxContainer/ShopItem3VBoxContainer/ShopItem3TextureButton
@onready var shop_item_3_name_label = $ShopItemsHBoxContainer/ShopItem3VBoxContainer/ShopItem3NameLabel

var items: Array[ItemObject] = []
var clicked_item_id: Util.ItemType = Util.ItemType.NONE


func init(available_items: Array[ItemObject]) -> void:
	assert(available_items.size() >= 3, 'Wrong available items size in shop')
	var all_items_indices = range(available_items.size())
	var min_range = mini(available_items.size(), 3)
	# hardcoded random max 3 items in shop
	for i in range(min_range):
		var random_item_index = all_items_indices.pick_random()
		items.push_back(available_items[random_item_index])
		all_items_indices.erase(random_item_index)
	
	assert(items.size() == 3, 'Wrong random items size in shop')
	shop_item_1_cost_label.text = str(items[0].cost) + '$'
	shop_item_1_texture_button.connect('mouse_entered', _on_texture_button_mouse_entered.bind(0))
	shop_item_1_texture_button.connect('mouse_exited', _on_texture_button_mouse_exited.bind(0))
	shop_item_1_texture_button.connect('pressed', _on_texture_button_pressed.bind(0))
	assert(items[0].textures.size() == 3, 'Wrong random item textures size')
	shop_item_1_texture_button.texture_normal = items[0].textures[0]
	shop_item_1_texture_button.texture_pressed = items[0].textures[1]
	shop_item_1_texture_button.texture_hover = items[0].textures[2]
	shop_item_1_texture_button.tooltip_text = items[0].description
	shop_item_1_name_label.text = items[0].item_name
	
	shop_item_2_cost_label.text = str(items[1].cost) + '$'
	shop_item_2_texture_button.connect('mouse_entered', _on_texture_button_mouse_entered.bind(1))
	shop_item_2_texture_button.connect('mouse_exited', _on_texture_button_mouse_exited.bind(1))
	shop_item_2_texture_button.connect('pressed', _on_texture_button_pressed.bind(1))
	assert(items[1].textures.size() == 3, 'Wrong random item textures size')
	shop_item_2_texture_button.texture_normal = items[1].textures[0]
	shop_item_2_texture_button.texture_pressed = items[1].textures[1]
	shop_item_2_texture_button.texture_hover = items[1].textures[2]
	shop_item_2_texture_button.tooltip_text = items[1].description
	shop_item_2_name_label.text = items[1].item_name
	
	shop_item_3_cost_label.text = str(items[2].cost) + '$'
	shop_item_3_texture_button.connect('mouse_entered', _on_texture_button_mouse_entered.bind(2))
	shop_item_3_texture_button.connect('mouse_exited', _on_texture_button_mouse_exited.bind(2))
	shop_item_3_texture_button.connect('pressed', _on_texture_button_pressed.bind(2))
	assert(items[2].textures.size() == 3, 'Wrong random item textures size')
	shop_item_3_texture_button.texture_normal = items[2].textures[0]
	shop_item_3_texture_button.texture_pressed = items[2].textures[1]
	shop_item_3_texture_button.texture_hover = items[2].textures[2]
	shop_item_3_texture_button.tooltip_text = items[2].description
	shop_item_3_name_label.text = items[2].item_name


func buy_item(item_id: Util.ItemType) -> void:
	if items[0].id == item_id:
		shop_item_1_cost_label.modulate.a = 0.5
		shop_item_1_texture_button.set_disabled(true)
		shop_item_1_texture_button.set_pressed_no_signal(false)
		shop_item_1_texture_button.modulate.a = 0.5
		shop_item_1_texture_button.tooltip_text = ''
		shop_item_1_name_label.modulate.a = 0.5
	elif items[1].id == item_id:
		shop_item_2_cost_label.modulate.a = 0.5
		shop_item_2_texture_button.set_disabled(true)
		shop_item_2_texture_button.set_pressed_no_signal(false)
		shop_item_2_texture_button.modulate.a = 0.5
		shop_item_2_texture_button.tooltip_text = ''
		shop_item_2_name_label.modulate.a = 0.5
	elif items[2].id == item_id:
		shop_item_3_cost_label.modulate.a = 0.5
		shop_item_3_texture_button.set_disabled(true)
		shop_item_3_texture_button.set_pressed_no_signal(false)
		shop_item_3_texture_button.modulate.a = 0.5
		shop_item_3_texture_button.tooltip_text = ''
		shop_item_3_name_label.modulate.a = 0.5


func reset_items(unclick_item_id: bool = true) -> void:
	shop_item_1_texture_button.set_pressed_no_signal(false)
	#shop_item_1_texture_button.modulate.a = (0.2) if (shop_item_1_texture_button.is_disabled()) else (0.5)
	shop_item_2_texture_button.set_pressed_no_signal(false)
	#shop_item_2_texture_button.modulate.a = (0.2) if (shop_item_2_texture_button.is_disabled()) else (0.5)
	shop_item_3_texture_button.set_pressed_no_signal(false)
	#shop_item_3_texture_button.modulate.a = (0.2) if (shop_item_3_texture_button.is_disabled()) else (0.5)
	if unclick_item_id:
		clicked_item_id = Util.ItemType.NONE


func _on_texture_button_mouse_entered(item_texture_index: int) -> void:
	var hovered_item = items[item_texture_index]
	if Global.money >= hovered_item.cost:
		item_hovered.emit(item_texture_index, hovered_item.id, true)


func _on_texture_button_mouse_exited(item_texture_index: int) -> void:
	var hovered_item = items[item_texture_index]
	if Global.money >= hovered_item.cost:
		item_hovered.emit(item_texture_index, hovered_item.id, false)


func _on_texture_button_pressed(item_texture_index: int) -> void:
	reset_items(false)
	
	var new_clicked_item = items[item_texture_index]
	if Global.money >= new_clicked_item.cost:
		if clicked_item_id != Util.ItemType.NONE and clicked_item_id == new_clicked_item.id:
			#texture_button.modulate.a = 0.5
			clicked_item_id = Util.ItemType.NONE
		else:
			if item_texture_index == 0:
				shop_item_1_texture_button.set_pressed_no_signal(true)
				#shop_item_1_texture_button.modulate.a = 1.0
			elif item_texture_index == 1:
				shop_item_2_texture_button.set_pressed_no_signal(true)
				#shop_item_2_texture_button.modulate.a = 1.0
			elif item_texture_index == 2:
				shop_item_3_texture_button.set_pressed_no_signal(true)
				#shop_item_3_texture_button.modulate.a = 1.0
			clicked_item_id = new_clicked_item.id
	else:
		clicked_item_id = Util.ItemType.NONE
	
	item_clicked.emit(item_texture_index, clicked_item_id)
