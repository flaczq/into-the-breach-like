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

# TODO FIXME zamienić na ItemObject tak jak w ActionTooltip
var items_ids: Array[Util.ItemType] = [Util.ItemType.NONE, Util.ItemType.NONE, Util.ItemType.NONE]
var clicked_item_id: Util.ItemType = Util.ItemType.NONE


func _ready() -> void:
	var random_items: Array[ItemObject] = []
	var available_items: Array[ItemObject] = Global.all_items.filter(func(item): return item.available)
	var all_items_indices = range(available_items.size())
	var min_range = mini(available_items.size(), 3)
	# hardcoded random max 3 items in shop
	for i in range(min_range):
		var random_item_index = all_items_indices.pick_random()
		random_items.push_back(available_items[random_item_index])
		all_items_indices.erase(random_item_index)
	
	assert(random_items.size() == 3, 'Wrong random items size in shop')
	var random_item_1 = random_items[0]
	items_ids[0] = random_item_1.id
	shop_item_1_cost_label.text = str(random_item_1.cost) + '$'
	shop_item_1_texture_button.connect('mouse_entered', _on_texture_button_mouse_entered.bind(0))
	shop_item_1_texture_button.connect('mouse_exited', _on_texture_button_mouse_exited.bind(0))
	shop_item_1_texture_button.connect('pressed', _on_texture_button_pressed.bind(0))
	assert(random_item_1.textures.size() == 3, 'Wrong random item textures size')
	shop_item_1_texture_button.texture_normal = random_item_1.textures[0]
	shop_item_1_texture_button.texture_pressed = random_item_1.textures[1]
	shop_item_1_texture_button.texture_hover = random_item_1.textures[2]
	shop_item_1_texture_button.tooltip_text = random_item_1.description
	shop_item_1_name_label.text = random_item_1.item_name
	
	var random_item_2 = random_items[1]
	items_ids[1] = random_item_2.id
	shop_item_2_cost_label.text = str(random_item_2.cost) + '$'
	shop_item_2_texture_button.connect('mouse_entered', _on_texture_button_mouse_entered.bind(1))
	shop_item_2_texture_button.connect('mouse_exited', _on_texture_button_mouse_exited.bind(1))
	shop_item_2_texture_button.connect('pressed', _on_texture_button_pressed.bind(1))
	assert(random_item_2.textures.size() == 3, 'Wrong random item textures size')
	shop_item_2_texture_button.texture_normal = random_item_2.textures[0]
	shop_item_2_texture_button.texture_pressed = random_item_2.textures[1]
	shop_item_2_texture_button.texture_hover = random_item_2.textures[2]
	shop_item_2_texture_button.tooltip_text = random_item_2.description
	shop_item_2_name_label.text = random_item_2.item_name
	
	var random_item_3 = random_items[2]
	items_ids[2] = random_item_3.id
	shop_item_3_cost_label.text = str(random_item_3.cost) + '$'
	shop_item_3_texture_button.connect('mouse_entered', _on_texture_button_mouse_entered.bind(2))
	shop_item_3_texture_button.connect('mouse_exited', _on_texture_button_mouse_exited.bind(2))
	shop_item_3_texture_button.connect('pressed', _on_texture_button_pressed.bind(2))
	assert(random_item_3.textures.size() == 3, 'Wrong random item textures size')
	shop_item_3_texture_button.texture_normal = random_item_3.textures[0]
	shop_item_3_texture_button.texture_pressed = random_item_3.textures[1]
	shop_item_3_texture_button.texture_hover = random_item_3.textures[2]
	shop_item_3_texture_button.tooltip_text = random_item_3.description
	shop_item_3_name_label.text = random_item_3.item_name


func item_bought(item_id: Util.ItemType) -> void:
	var item_texture_index = items_ids.find(item_id)
	if item_texture_index == 0:
		shop_item_1_cost_label.modulate.a = 0.5
		shop_item_1_texture_button.set_disabled(true)
		shop_item_1_texture_button.set_pressed_no_signal(false)
		shop_item_1_texture_button.modulate.a = 0.5
		shop_item_1_name_label.modulate.a = 0.5
	elif item_texture_index == 1:
		shop_item_2_cost_label.modulate.a = 0.5
		shop_item_2_texture_button.set_disabled(true)
		shop_item_2_texture_button.set_pressed_no_signal(false)
		shop_item_2_texture_button.modulate.a = 0.5
		shop_item_2_name_label.modulate.a = 0.5
	elif item_texture_index == 2:
		shop_item_3_cost_label.modulate.a = 0.5
		shop_item_3_texture_button.set_disabled(true)
		shop_item_3_texture_button.set_pressed_no_signal(false)
		shop_item_3_texture_button.modulate.a = 0.5
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
	var hovered_item_id = items_ids[item_texture_index]
	var hovered_item = Util.get_item(hovered_item_id)
	if Global.money >= hovered_item.cost:
		item_hovered.emit(item_texture_index, hovered_item_id, true)


func _on_texture_button_mouse_exited(item_texture_index: int) -> void:
	var hovered_item_id = items_ids[item_texture_index]
	var hovered_item = Util.get_item(hovered_item_id)
	if Global.money >= hovered_item.cost:
		item_hovered.emit(item_texture_index, hovered_item_id, false)


func _on_texture_button_pressed(item_texture_index: int) -> void:
	reset_items(false)
	
	var new_clicked_item_id = items_ids[item_texture_index]
	var new_clicked_item = Util.get_item(new_clicked_item_id)
	if Global.money >= new_clicked_item.cost:
		if clicked_item_id != Util.ItemType.NONE and clicked_item_id == new_clicked_item_id:
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
			clicked_item_id = new_clicked_item_id
	else:
		clicked_item_id = Util.ItemType.NONE
	
	item_clicked.emit(item_texture_index, clicked_item_id)
