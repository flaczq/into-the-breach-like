extends Node

class_name Shop

signal item_hovered(target_item_id: Util.ItemType, is_hovered: bool)
signal item_clicked(target_item_id: Util.ItemType, is_clicked: bool)

var items_ids: Array[Util.ItemType] = []


func _ready() -> void:
	var random_items: Array[ItemObject] = []
	var all_items_indices = range(Global.all_items.size())
	# hardcoded 3 items in shop
	for i in range(3):
		var random_item_index = all_items_indices.pick_random()
		random_items.push_back(Global.all_items[random_item_index])
		all_items_indices.erase(random_item_index)
	
	assert(random_items.size() == 3, 'Wrong random items size in shop')
	var v_box_container_id = 1
	for random_item in random_items:
		var item_id: Util.ItemType = random_item.id
		items_ids.push_back(item_id)
		
		var shop_items = find_child('ShopItemsHBoxContainer') as HBoxContainer
		var shop_item = shop_items.find_child('ShopItem' + str(v_box_container_id) + 'VBoxContainer') as VBoxContainer
		var cost_label = shop_item.find_child('ShopItem' + str(v_box_container_id) + 'CostLabel') as Label
		cost_label.text = str(random_item.cost) + '$'
		
		var texture_button = shop_item.find_child('ShopItem' + str(v_box_container_id) + 'TextureButton') as TextureButton
		texture_button.connect('toggled', _on_texture_button_toggled.bind(item_id))
		texture_button.texture_normal = random_item.texture
		texture_button.modulate.a = 1.0
		
		var name_label = shop_item.find_child('ShopItem' + str(v_box_container_id) + 'NameLabel') as Label
		name_label.text = random_item.item_name
		
		v_box_container_id += 1


func _on_texture_button_mouse_entered(item_id: Util.ItemType) -> void:
	item_hovered.emit(item_id, true)


func _on_texture_button_mouse_exited(item_id: Util.ItemType) -> void:
	item_hovered.emit(item_id, false)


func _on_texture_button_toggled(toggled_on: bool, item_id: Util.ItemType) -> void:
	var v_box_container_id = items_ids.find(item_id) + 1
	var shop_items = find_child('ShopItemsHBoxContainer') as HBoxContainer
	var id = 1
	for texture_button in shop_items.find_children('TextureButton', 'TextureButton') as Array[TextureButton]:
		if items_ids[id]:
			texture_button.modulate.a = 1.0
		else:
			texture_button.modulate.a = 0.5
		
		id += 1
	
	item_clicked.emit(item_id, toggled_on)
