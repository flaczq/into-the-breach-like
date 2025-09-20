extends Node

class_name Inventory

signal item_hovered(item_texture_index: int, item_id: Util.ItemType, is_hovered: bool)
signal item_clicked(item_texture_index: int, item_id: Util.ItemType)

@onready var inventory_item_1_texture_button = $InventoryItemsGridContainer/InventoryItemSlot1TextureButton/InventoryItem1TextureButton
@onready var inventory_item_2_texture_button = $InventoryItemsGridContainer/InventoryItemSlot2TextureButton/InventoryItem2TextureButton
@onready var inventory_item_3_texture_button = $InventoryItemsGridContainer/InventoryItemSlot3TextureButton/InventoryItem3TextureButton
@onready var inventory_item_4_texture_button = $InventoryItemsGridContainer/InventoryItemSlot4TextureButton/InventoryItem4TextureButton
@onready var inventory_item_5_texture_button = $InventoryItemsGridContainer/InventoryItemSlot5TextureButton/InventoryItem5TextureButton
@onready var inventory_item_6_texture_button = $InventoryItemsGridContainer/InventoryItemSlot6TextureButton/InventoryItem6TextureButton
@onready var inventory_item_7_texture_button = $InventoryItemsGridContainer/InventoryItemSlot7TextureButton/InventoryItem7TextureButton
@onready var inventory_item_8_texture_button = $InventoryItemsGridContainer/InventoryItemSlot8TextureButton/InventoryItem8TextureButton

var inventory_items_texture_buttons: Array[TextureButton]
var empty_item: ItemObject

var items: Array[ItemObject]		= []
var clicked_item_id: Util.ItemType	= Util.ItemType.NONE


func _ready() -> void:
	inventory_items_texture_buttons = [
		inventory_item_1_texture_button,
		inventory_item_2_texture_button,
		inventory_item_3_texture_button,
		inventory_item_4_texture_button,
		inventory_item_5_texture_button,
		inventory_item_6_texture_button,
		inventory_item_7_texture_button,
		inventory_item_8_texture_button
	]


func init(bought_items: Array[ItemObject], new_empty_item: ItemObject) -> void:
	empty_item = new_empty_item
	items.resize(8)
	items.fill(empty_item)
	
	var index = 0
	for inventory_item_texture_button in inventory_items_texture_buttons:
		inventory_item_texture_button.connect('mouse_entered', _on_texture_button_mouse_entered.bind(index))
		inventory_item_texture_button.connect('mouse_exited', _on_texture_button_mouse_exited.bind(index))
		inventory_item_texture_button.connect('pressed', _on_texture_button_pressed.bind(index))
		index += 1
	
	for bought_item in bought_items:
		assert(bought_item.id >= 0, 'Wrong selected item id')
		add_item(bought_item)


func find_first_empty_index() -> int:
	var index = 0
	for item in items:
		if item.id == Util.ItemType.NONE:
			return index
		index += 1
	return -1


# maybe not useful?
func update_items() -> void:
	var index = 0
	for texture_button in inventory_items_texture_buttons:
		if items[index].id != Util.ItemType.NONE:
			assert(texture_button.textures.size() == 3, 'Wrong inventory item textures size')
			texture_button.texture_normal = items[index].textures[0]
			texture_button.texture_pressed = items[index].textures[1]
			texture_button.texture_hover = items[index].textures[2]
			texture_button.tooltip_text = items[index].description
		else:
			texture_button.texture_normal = null
			texture_button.texture_pressed = null
			texture_button.texture_hover = null
			texture_button.tooltip_text = 'no item\navailable\nfor you'
		index += 1


func add_item(item: ItemObject, target_item_texture_index: int = -1) -> void:
	if item.id != Util.ItemType.NONE:
		var item_texture_index = (target_item_texture_index) if (target_item_texture_index >= 0) else (find_first_empty_index())
		assert(item_texture_index >= 0, 'No empty space in inventory')
		var texture_button = inventory_items_texture_buttons[item_texture_index]
		assert(item.textures.size() == 3, 'Wrong item object textures size')
		texture_button.texture_normal = item.textures[0]
		texture_button.texture_pressed = item.textures[1]
		texture_button.texture_hover = item.textures[2]
		texture_button.tooltip_text = item.description
		#texture_button.modulate.a = 1.0
		items[item_texture_index] = item


func remove_item(item_id: Util.ItemType) -> void:
	var removed_item = items.filter(func(item): return item.id == item_id).front()
	assert(removed_item, 'Removed item not in inventory')
	var item_texture_index = items.find(removed_item)
	var texture_button = inventory_items_texture_buttons[item_texture_index]
	texture_button.texture_normal = null
	texture_button.texture_pressed = null
	texture_button.texture_hover = null
	texture_button.tooltip_text = 'NO ITEM'
	#texture_button.modulate.a = 0.5
	items[item_texture_index] = empty_item


func move_item(item: ItemObject, target_item_texture_index: int) -> void:
	if item.id != Util.ItemType.NONE:
		remove_item(item.id)
	
	assert(items[target_item_texture_index].id == Util.ItemType.NONE, 'Target inventory space not empty')
	add_item(item, target_item_texture_index)


func reset_items(is_highlighted: bool = false) -> void:
	var index = 0
	for inventory_item_texture_button in inventory_items_texture_buttons:
		inventory_item_texture_button.set_pressed_no_signal(false)
		#inventory_item_texture_button.modulate.a = (1.0) if (is_highlighted or item_ids[index] != Util.ItemType.NONE) else (0.5)
		index += 1
	clicked_item_id = Util.ItemType.NONE


func _on_texture_button_mouse_entered(item_texture_index: int) -> void:
	var hovered_item = items[item_texture_index]
	item_hovered.emit(item_texture_index, hovered_item.id, true)


func _on_texture_button_mouse_exited(item_texture_index: int) -> void:
	var hovered_item = items[item_texture_index]
	item_hovered.emit(item_texture_index, hovered_item.id, false)


func _on_texture_button_pressed(item_texture_index: int) -> void:
	var new_clicked_item = items[item_texture_index]
	# clicked empty inventory item when nothing was clicked before
	if clicked_item_id != Util.ItemType.NONE or new_clicked_item.id != Util.ItemType.NONE:
		var index = 0
		for inventory_item_texture_button in inventory_items_texture_buttons:
			inventory_item_texture_button.set_pressed_no_signal(false)
			index += 1
		
		var texture_button = inventory_items_texture_buttons[item_texture_index]
		if clicked_item_id != Util.ItemType.NONE and clicked_item_id == new_clicked_item.id:
			# unclick item
			#texture_button.modulate.a = 1.0
			clicked_item_id = Util.ItemType.NONE
		else:
			if new_clicked_item.id == Util.ItemType.NONE:
				var clicked_item = items.filter(func(item): return item.id == clicked_item_id).front()
				move_item(clicked_item, item_texture_index)
				clicked_item_id = Util.ItemType.NONE
			else:
				texture_button.set_pressed_no_signal(true)
				#texture_button.modulate.a = 1.0
				clicked_item_id = new_clicked_item.id
	
	item_clicked.emit(item_texture_index, clicked_item_id)
