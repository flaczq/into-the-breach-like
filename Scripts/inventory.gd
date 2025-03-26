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

# TODO FIXME zamienić na ItemObject tak jak w ActionTooltip
var items_ids: Array[Util.ItemType] = [
	Util.ItemType.NONE,
	Util.ItemType.NONE,
	Util.ItemType.NONE,
	Util.ItemType.NONE,
	Util.ItemType.NONE,
	Util.ItemType.NONE,
	Util.ItemType.NONE,
	Util.ItemType.NONE
]
var clicked_item_id: Util.ItemType = Util.ItemType.NONE


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

	var index = 0
	for inventory_item_texture_button in inventory_items_texture_buttons:
		inventory_item_texture_button.connect('mouse_entered', _on_texture_button_mouse_entered.bind(index))
		inventory_item_texture_button.connect('mouse_exited', _on_texture_button_mouse_exited.bind(index))
		inventory_item_texture_button.connect('pressed', _on_texture_button_pressed.bind(index))
		index += 1
	
	for selected_item in Global.selected_items:
		assert(selected_item.id >= 0, 'Wrong selected item id')
		add_item(selected_item)


func add_item(item_object: ItemObject, target_item_texture_index: int = -1) -> void:
	var item_id: Util.ItemType = item_object.id
	var item_texture_index = (target_item_texture_index) if (target_item_texture_index >= 0) else (items_ids.find(Util.ItemType.NONE))
	var texture_button = inventory_items_texture_buttons[item_texture_index]
	assert(item_object.textures.size() == 3, 'Wrong item object textures size')
	texture_button.texture_normal = item_object.textures[0]
	texture_button.texture_pressed = item_object.textures[1]
	texture_button.texture_hover = item_object.textures[2]
	texture_button.tooltip_text = item_object.description
	#texture_button.modulate.a = 1.0
	items_ids[item_texture_index] = item_id


func remove_item(item_id: Util.ItemType) -> void:
	var item_texture_index = items_ids.find(item_id)
	var texture_button = inventory_items_texture_buttons[item_texture_index]
	texture_button.texture_normal = null
	texture_button.texture_pressed = null
	texture_button.texture_hover = null
	texture_button.tooltip_text = 'NO ITEM'
	#texture_button.modulate.a = 0.5
	items_ids[item_texture_index] = Util.ItemType.NONE


func move_item(item_id: Util.ItemType, item_texture_index: int) -> void:
	var item = Util.get_selected_item(item_id)
	if item_id != Util.ItemType.NONE:
		remove_item(item_id)
	
	assert(items_ids[item_texture_index] == Util.ItemType.NONE, 'Target inventory item not empty')
	add_item(item, item_texture_index)


func reset_items(is_highlighted: bool = false) -> void:
	var index = 0
	for inventory_item_texture_button in inventory_items_texture_buttons:
		inventory_item_texture_button.set_pressed_no_signal(false)
		#inventory_item_texture_button.modulate.a = (1.0) if (is_highlighted or items_ids[index] != Util.ItemType.NONE) else (0.5)
		index += 1
	clicked_item_id = Util.ItemType.NONE


func _on_texture_button_mouse_entered(item_texture_index: int) -> void:
	var hovered_item_id = items_ids[item_texture_index]
	item_hovered.emit(item_texture_index, hovered_item_id, true)


func _on_texture_button_mouse_exited(item_texture_index: int) -> void:
	var hovered_item_id = items_ids[item_texture_index]
	item_hovered.emit(item_texture_index, hovered_item_id, false)


func _on_texture_button_pressed(item_texture_index: int) -> void:
	var new_clicked_item_id = items_ids[item_texture_index]
	# clicked empty inventory item when nothing was clicked before
	if clicked_item_id != Util.ItemType.NONE or new_clicked_item_id != Util.ItemType.NONE:
		var index = 0
		for inventory_item_texture_button in inventory_items_texture_buttons:
			inventory_item_texture_button.set_pressed_no_signal(false)
			#if items_ids[index] == Util.ItemType.NONE:
				## highlight empty inventory items to move clicked item to
				#inventory_item_texture_button.modulate.a = (1.0) if (new_clicked_item_id != Util.ItemType.NONE and clicked_item_id != new_clicked_item_id) else (0.5)
			#else:
				#inventory_item_texture_button.modulate.a = 1.0
			index += 1
		
		var texture_button = inventory_items_texture_buttons[item_texture_index]
		if clicked_item_id != Util.ItemType.NONE and clicked_item_id == new_clicked_item_id:
			# unclick item
			#texture_button.modulate.a = 1.0
			clicked_item_id = Util.ItemType.NONE
		else:
			if new_clicked_item_id == Util.ItemType.NONE:
				move_item(clicked_item_id, item_texture_index)
				clicked_item_id = Util.ItemType.NONE
			else:
				texture_button.set_pressed_no_signal(true)
				#texture_button.modulate.a = 1.0
				clicked_item_id = new_clicked_item_id
	
	item_clicked.emit(item_texture_index, clicked_item_id)
