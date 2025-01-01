extends Node

class_name Inventory

var empty_item_texture: CompressedTexture2D = preload('res://Assets/penzilla.vector-icon-pack/Icon_SquareStraight.png')

var items_ids: Array[int]


func _ready() -> void:
	for selected_item_id in Global.selected_items_ids:
		assert(selected_item_id >= 0, 'Wrong selected item id')
		items_ids.push_back(selected_item_id)


func add_item(item_object: ItemObject) -> void:
	var item_id = item_object.id
	items_ids.push_back(item_id)
	
	var next_id = items_ids.size()
	var items_grid_container = find_child('ItemsGridContainer') as GridContainer
	var item_texture_rect = items_grid_container.find_child('Item' + str(next_id) + 'TextureRect') as TextureRect
	item_texture_rect.texture = item_object.texture
	item_texture_rect.modulate.a = 1.0


func remove_item(item_object: ItemObject) -> void:
	var item_id = item_object.id
	
	var current_id = items_ids.find(item_id) + 1
	assert(current_id > 0, 'Wrong current id for removed item')
	var items_grid_container = find_child('ItemsGridContainer') as GridContainer
	var item_texture_rect = items_grid_container.find_child('Item' + str(current_id) + 'TextureRect') as TextureRect
	item_texture_rect.texture = empty_item_texture
	item_texture_rect.modulate.a = 0.5
	
	items_ids.erase(item_object.id)
