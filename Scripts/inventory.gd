extends Node

class_name Inventory

signal item_hovered(target_item_id: Util.ItemType, is_hovered: bool)
signal item_clicked(target_item_id: Util.ItemType, is_clicked: bool)

var empty_item_texture: CompressedTexture2D = preload('res://Assets/penzilla.vector-icon-pack/Icon_SquareStraight.png')

var items_ids: Array[Util.ItemType] = []
var is_item_hovered: bool = false
var is_item_clicked: bool = false


func _ready() -> void:
	for selected_item_id in Global.selected_items_ids:
		assert(selected_item_id >= 0, 'Wrong selected item id')
		var selected_item = Global.all_items.filter(func(item): return item.id == selected_item_id).front()
		add_item(selected_item)


func add_item(item_object: ItemObject) -> void:
	var item_id: Util.ItemType = item_object.id
	items_ids.push_back(item_id)
	
	var texture_button_id = items_ids.size()
	var inventory_items = find_child('InventoryItemsGridContainer') as GridContainer
	var texture_button = inventory_items.find_child('InventoryItem' + str(texture_button_id) + 'TextureButton') as TextureButton
	texture_button.connect('mouse_entered', _on_texture_button_mouse_entered.bind(item_id))
	texture_button.connect('mouse_exited', _on_texture_button_mouse_exited.bind(item_id))
	texture_button.connect('toggled', _on_texture_button_toggled.bind(item_id))
	texture_button.texture = item_object.texture
	texture_button.modulate.a = 1.0


func remove_item(item_object: ItemObject) -> void:
	var item_id: Util.ItemType = item_object.id
	
	var texture_button_id = items_ids.find(item_id) + 1
	var inventory_items = find_child('InventoryItemsGridContainer') as GridContainer
	var texture_button = inventory_items.find_child('InventoryItem' + str(texture_button_id) + 'TextureButton') as TextureButton
	texture_button.texture = empty_item_texture
	texture_button.modulate.a = 0.5
	
	items_ids.erase(item_object.id)


func _on_texture_button_mouse_entered(item_id: Util.ItemType) -> void:
	is_item_hovered = true
	item_hovered.emit(item_id, true)


func _on_texture_button_mouse_exited(item_id: Util.ItemType) -> void:
	is_item_hovered = false
	item_hovered.emit(item_id, false)


func _on_texture_button_toggled(toggled_on: bool, item_id: Util.ItemType) -> void:
	var texture_button_id = items_ids.find(item_id) + 1
	var inventory_items = find_child('InventoryItemsGridContainer') as GridContainer
	var id = 1
	for texture_button in inventory_items.find_children('TextureButton', 'TextureButton') as Array[TextureButton]:
		if items_ids[id]:
			#texture_button.modulate.a = (1.0) if (is_item_hovered) else (0.5)
			texture_button.modulate.a = 1.0
		else:
			texture_button.modulate.a = 0.5
		
		id += 1
	
	item_clicked.emit(item_id, toggled_on)
