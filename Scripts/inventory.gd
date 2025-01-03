extends Node

class_name Inventory

signal item_hovered(inventory_item_id: int, item_id: Util.ItemType, is_hovered: bool)
signal item_clicked(inventory_item_id: int, item_id: Util.ItemType)

@onready var inventory_item_1_texture_button = $InventoryBackgroundTextureRect/InventoryItemsGridContainer/InventoryItem1TextureButton
@onready var inventory_item_2_texture_button = $InventoryBackgroundTextureRect/InventoryItemsGridContainer/InventoryItem2TextureButton
@onready var inventory_item_3_texture_button = $InventoryBackgroundTextureRect/InventoryItemsGridContainer/InventoryItem3TextureButton
@onready var inventory_item_4_texture_button = $InventoryBackgroundTextureRect/InventoryItemsGridContainer/InventoryItem4TextureButton
@onready var inventory_item_5_texture_button = $InventoryBackgroundTextureRect/InventoryItemsGridContainer/InventoryItem5TextureButton
@onready var inventory_item_6_texture_button = $InventoryBackgroundTextureRect/InventoryItemsGridContainer/InventoryItem6TextureButton
@onready var inventory_item_7_texture_button = $InventoryBackgroundTextureRect/InventoryItemsGridContainer/InventoryItem7TextureButton
@onready var inventory_item_8_texture_button = $InventoryBackgroundTextureRect/InventoryItemsGridContainer/InventoryItem8TextureButton

var empty_item_texture: CompressedTexture2D = preload('res://Assets/penzilla.vector-icon-pack/Icon_SquareStraight.png')

var inventory_items_texture_buttons: Array[TextureButton]

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

	var id = 1
	for inventory_item_texture_button in inventory_items_texture_buttons:
		inventory_item_texture_button.connect('mouse_entered', _on_texture_button_mouse_entered.bind(id))
		inventory_item_texture_button.connect('mouse_exited', _on_texture_button_mouse_exited.bind(id))
		inventory_item_texture_button.connect('pressed', _on_texture_button_pressed.bind(id))
		id += 1
	
	for selected_item_id in Global.selected_items_ids:
		assert(selected_item_id >= 0, 'Wrong selected item id')
		var selected_item = Global.all_items.filter(func(item): return item.id == selected_item_id).front()
		add_item(selected_item)


func add_item(item_object: ItemObject) -> void:
	var item_id: Util.ItemType = item_object.id
	var new_inventory_item_id = items_ids.find(Util.ItemType.NONE) + 1
	assert(new_inventory_item_id >= 1 and new_inventory_item_id <= 8, 'Wrong inventory item id')
	var inventory_items = find_child('InventoryItemsGridContainer') as GridContainer
	var texture_button = inventory_items.find_child('InventoryItem' + str(new_inventory_item_id) + 'TextureButton') as TextureButton
	texture_button.texture_normal = item_object.texture
	texture_button.modulate.a = 1.0
	
	items_ids[new_inventory_item_id - 1] = item_id


func remove_item(item_object: ItemObject) -> void:
	var item_id: Util.ItemType = item_object.id
	var inventory_item_id = items_ids.find(item_id) + 1
	var inventory_items = find_child('InventoryItemsGridContainer') as GridContainer
	var texture_button = inventory_items.find_child('InventoryItem' + str(inventory_item_id) + 'TextureButton') as TextureButton
	texture_button.texture_normal = empty_item_texture
	texture_button.modulate.a = 0.5
	
	items_ids[inventory_item_id - 1] = Util.ItemType.NONE


func move_item(item_id: Util.ItemType, new_inventory_item_id: int) -> void:
	var inventory_item_id = items_ids.find(item_id) + 1
	items_ids[inventory_item_id - 1] = Util.ItemType.NONE
	
	assert(not items_ids[new_inventory_item_id], 'New inventory item not empty')
	items_ids[new_inventory_item_id] = item_id


func _on_texture_button_mouse_entered(inventory_item_id: int) -> void:
	var hovered_item_id = items_ids[inventory_item_id - 1]
	item_hovered.emit(inventory_item_id, hovered_item_id, true)


func _on_texture_button_mouse_exited(inventory_item_id: int) -> void:
	var hovered_item_id = items_ids[inventory_item_id - 1]
	item_hovered.emit(inventory_item_id, hovered_item_id, false)


func _on_texture_button_pressed(inventory_item_id: int) -> void:
	# clicked empty inventory item
	if not clicked_item_id or items_ids[inventory_item_id - 1] == Util.ItemType.NONE:
		return
	
	# show empty inventory items to move selected item
	var index = 0
	for inventory_item_texture_button in inventory_items_texture_buttons:
		inventory_item_texture_button.set_pressed_no_signal(false)
		inventory_item_texture_button.modulate.a = (0.5) if (items_ids[index] == Util.ItemType.NONE) else (1.0)
		index += 1
	
	var inventory_items = find_child('InventoryItemsGridContainer') as GridContainer
	var texture_button = inventory_items.find_child('InventoryItem' + str(inventory_item_id) + 'TextureButton') as TextureButton
	
	if clicked_item_id != Util.ItemType.NONE and clicked_item_id == items_ids[inventory_item_id - 1]:
		texture_button.modulate.a = 0.5
		clicked_item_id = Util.ItemType.NONE
	else:
		#move_item(clicked_item_id, inventory_item_id - 1)
		texture_button.set_pressed_no_signal(true)
		texture_button.modulate.a = 1.0
		clicked_item_id = items_ids[inventory_item_id - 1]
	
	item_clicked.emit(inventory_item_id, clicked_item_id)
