extends Node

class_name Shop

signal item_hovered(shop_item_id: int, item_id: Util.ItemType, is_hovered: bool)
signal item_clicked(shop_item_id: int, item_id: Util.ItemType)

@onready var shop_item_1_texture_button = $ShopBackgroundTextureRect/ShopItemsHBoxContainer/ShopItem1VBoxContainer/ShopItem1TextureButton
@onready var shop_item_2_texture_button = $ShopBackgroundTextureRect/ShopItemsHBoxContainer/ShopItem2VBoxContainer/ShopItem2TextureButton
@onready var shop_item_3_texture_button = $ShopBackgroundTextureRect/ShopItemsHBoxContainer/ShopItem3VBoxContainer/ShopItem3TextureButton

var shop_items_texture_buttons: Array[TextureButton]

var items_ids: Array[Util.ItemType] = [Util.ItemType.NONE, Util.ItemType.NONE, Util.ItemType.NONE]
var clicked_item_id: Util.ItemType = Util.ItemType.NONE

func _ready() -> void:
	shop_items_texture_buttons = [
		shop_item_1_texture_button,
		shop_item_2_texture_button,
		shop_item_3_texture_button
	]

	var random_items: Array[ItemObject] = []
	var all_items_indices = range(Global.all_items.size())
	# hardcoded 3 items in shop
	for i in range(3):
		var random_item_index = all_items_indices.pick_random()
		random_items.push_back(Global.all_items[random_item_index])
		all_items_indices.erase(random_item_index)
	
	assert(random_items.size() == 3, 'Wrong random items size in shop')
	var shop_item_id = 1
	for random_item in random_items:
		var item_id: Util.ItemType = random_item.id
		items_ids[shop_item_id - 1] = item_id
		
		var shop_items = find_child('ShopItemsHBoxContainer') as HBoxContainer
		var shop_item = shop_items.find_child('ShopItem' + str(shop_item_id) + 'VBoxContainer') as VBoxContainer
		var cost_label = shop_item.find_child('ShopItem' + str(shop_item_id) + 'CostLabel') as Label
		cost_label.text = str(random_item.cost) + '$'
		
		var texture_button = shop_item.find_child('ShopItem' + str(shop_item_id) + 'TextureButton') as TextureButton
		texture_button.connect('mouse_entered', _on_texture_button_mouse_entered.bind(shop_item_id))
		texture_button.connect('mouse_exited', _on_texture_button_mouse_exited.bind(shop_item_id))
		texture_button.connect('pressed', _on_texture_button_pressed.bind(shop_item_id))
		texture_button.texture_normal = random_item.texture
		texture_button.modulate.a = 0.5
		
		var name_label = shop_item.find_child('ShopItem' + str(shop_item_id) + 'NameLabel') as Label
		name_label.text = random_item.item_name
		
		shop_item_id += 1


func item_bought(item_id: Util.ItemType) -> void:
	var shop_item_id = items_ids.find(item_id) + 1
	var shop_items = find_child('ShopItemsHBoxContainer') as HBoxContainer
	var shop_item = shop_items.find_child('ShopItem' + str(shop_item_id) + 'VBoxContainer') as VBoxContainer
	var texture_button = shop_item.find_child('ShopItem' + str(shop_item_id) + 'TextureButton') as TextureButton
	texture_button.set_disabled(true)
	texture_button.set_pressed_no_signal(false)
	texture_button.modulate.a = 0.2
	#texture_button.flip_v = true
	
	var cost_label = shop_item.find_child('ShopItem' + str(shop_item_id) + 'CostLabel') as Label
	cost_label.modulate.a = 0.2
	
	var name_label = shop_item.find_child('ShopItem' + str(shop_item_id) + 'NameLabel') as Label
	name_label.modulate.a = 0.2
	
	clicked_item_id = Util.ItemType.NONE


func _on_texture_button_mouse_entered(shop_item_id: int) -> void:
	var hovered_item_id = items_ids[shop_item_id - 1]
	var hovered_item = Util.get_item(hovered_item_id)
	if Global.money >= hovered_item.cost:
		item_hovered.emit(shop_item_id, hovered_item_id, true)


func _on_texture_button_mouse_exited(shop_item_id: int) -> void:
	var hovered_item_id = items_ids[shop_item_id - 1]
	var hovered_item = Util.get_item(hovered_item_id)
	if Global.money >= hovered_item.cost:
		item_hovered.emit(shop_item_id, hovered_item_id, false)


func _on_texture_button_pressed(shop_item_id: int) -> void:
	for shop_item_texture_button in shop_items_texture_buttons:
		shop_item_texture_button.set_pressed_no_signal(false)
		shop_item_texture_button.modulate.a = (0.2) if (shop_item_texture_button.is_disabled()) else (0.5)
	
	var new_clicked_item_id = items_ids[shop_item_id - 1]
	var new_clicked_item = Util.get_item(new_clicked_item_id)
	if Global.money >= new_clicked_item.cost:
		var shop_items = find_child('ShopItemsHBoxContainer') as HBoxContainer
		var shop_item = shop_items.find_child('ShopItem' + str(shop_item_id) + 'VBoxContainer') as VBoxContainer
		var texture_button = shop_item.find_child('ShopItem' + str(shop_item_id) + 'TextureButton') as TextureButton
		
		if clicked_item_id != Util.ItemType.NONE and clicked_item_id == new_clicked_item_id:
			texture_button.modulate.a = 0.5
			clicked_item_id = Util.ItemType.NONE
		else:
			texture_button.set_pressed_no_signal(true)
			texture_button.modulate.a = 1.0
			clicked_item_id = new_clicked_item_id
	else:
		clicked_item_id = Util.ItemType.NONE
	
	item_clicked.emit(shop_item_id, clicked_item_id)
