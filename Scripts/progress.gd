extends Util

@export var item_container_scene: PackedScene

@onready var menu: Menu = $/root/Menu
@onready var game_state_manager: GameStateManager = $/root/Main/GameStateManager
@onready var canvas_layer = $CanvasLayer
@onready var upgrades_container = $CanvasLayer/PanelCenterContainer/UpgradesContainer
@onready var shop_label = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopLabel
@onready var shop: Shop = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/Shop
@onready var shop_buy_texture_button = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopButtonsHBoxContainer/ShopBuyTextureButton
@onready var shop_skip_texture_button = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopButtonsHBoxContainer/ShopSkipTextureButton
@onready var inventory_label = $CanvasLayer/PanelCenterContainer/UpgradesContainer/InventoryContainer/InventoryLabel
@onready var players_grid_container = $CanvasLayer/PanelCenterContainer/UpgradesContainer/InventoryContainer/PlayersGridContainer
@onready var inventory: Inventory = $CanvasLayer/PanelCenterContainer/UpgradesContainer/InventoryContainer/Inventory
@onready var levels_container = $CanvasLayer/PanelCenterContainer/LevelsContainer
@onready var levels_next_texture_button = $CanvasLayer/PanelCenterContainer/LevelsContainer/LevelsNextTextureButton

var selected_level_type: LevelType = LevelType.NONE


func _ready() -> void:
	Global.engine_mode = EngineMode.MENU
	Global.money = 5
	
	if Global.money > 0:
		upgrades_container.show()
		levels_container.hide()
	else:
		upgrades_container.hide()
		levels_container.show()
	
	on_button_disabled(shop_buy_texture_button, true)
	on_button_disabled(shop_skip_texture_button, false)
	on_button_disabled(levels_next_texture_button, true)
	inventory_label.text = 'INVENTORY'
	
	update_labels()
	init_ui()


func init_ui() -> void:
	shop.connect('item_hovered', _on_shop_item_hovered)
	shop.connect('item_clicked', _on_shop_item_clicked)
	
	inventory.connect('item_hovered', _on_inventory_item_hovered)
	inventory.connect('item_clicked', _on_inventory_item_clicked)
	
	for child in players_grid_container.get_children():
		child.hide()
	
	assert(Global.selected_players.size() > 0 and Global.selected_players.size() <= 3, 'Wrong selected players size')
	var index = 0
	for player in Global.selected_players as Array[PlayerObject]:
		assert(player.id != PlayerType.NONE, 'Wrong selected player id')
		var player_inventory = players_grid_container.get_child(index) as PlayerInventory
		player_inventory.init(player.id, player.textures, player.action_1_textures, player.action_2_textures, player.max_health, player.move_distance)
		player_inventory.connect('player_inventory_mouse_entered', _on_player_inventory_mouse_entered)
		player_inventory.connect('player_inventory_mouse_exited', _on_player_inventory_mouse_exited)
		player_inventory.connect('player_inventory_toggled', _on_player_inventory_toggled)
		#player_inventory.texture_rect.scale = Vector2(0.75, 0.75)
		player_inventory.show()
		index += 1
	assert(players_grid_container.get_child_count() >= index, 'Wrong player stats size')


func update_labels() -> void:
	shop_label.text = 'Welcome to the SHOP\nMoney: ' + str(Global.money)


func show_back() -> void:
	Global.engine_mode = EngineMode.MENU
	toggle_visibility(true)


func get_shop_clicked_item_id() -> ItemType:
	return shop.clicked_item_id


func get_player_clicked_item_id(player_id: PlayerType = PlayerType.NONE) -> ItemType:
	if player_id != PlayerType.NONE:
		var player_inventory = players_grid_container.get_children().filter(func(child): return child.id == player_id and child.clicked_item_id != ItemType.NONE).front() as PlayerInventory
		if player_inventory:
			return player_inventory.clicked_item_id
	
	var player_inventory = players_grid_container.get_children().filter(func(child): return child.clicked_item_id != ItemType.NONE).front() as PlayerInventory
	if player_inventory:
		return player_inventory.clicked_item_id
	
	return ItemType.NONE


func get_inventory_clicked_item_id() -> ItemType:
	return inventory.clicked_item_id


func _on_menu_button_pressed() -> void:
	toggle_visibility(false)
	menu.show_in_game_menu(self)


func _on_shop_item_hovered(shop_item_id: int, item_id: ItemType, is_hovered: bool) -> void:
	#print('_on_shop_item_hovered' + str(item_id) + str(is_hovered))
	pass


func _on_shop_item_clicked(shop_item_id: int, item_id: ItemType) -> void:
	var shop_clicked_item_id = get_shop_clicked_item_id()
	if shop_clicked_item_id == ItemType.NONE:
		on_button_disabled(shop_buy_texture_button, true)
	else:
		var selected_item_from_shop = get_item(shop_clicked_item_id)
		on_button_disabled(shop_buy_texture_button, selected_item_from_shop.cost > Global.money)
	
	for player_inventory in players_grid_container.get_children() as Array[PlayerInventory]:
		player_inventory.reset_items()
	inventory.reset_items()


func _on_shop_buy_texture_button_pressed() -> void:
	on_button_disabled(shop_buy_texture_button, true)
	
	var shop_clicked_item_id = get_shop_clicked_item_id()
	if shop_clicked_item_id == ItemType.NONE:
		return
	
	var selected_item_from_shop = get_item(shop_clicked_item_id)
	if selected_item_from_shop.cost > Global.money:
		return
	
	selected_item_from_shop.available = false
	
	var new_selected_item_from_shop = selected_item_from_shop.duplicate()
	new_selected_item_from_shop.init_from_item_object(selected_item_from_shop)
	Global.selected_items.push_back(new_selected_item_from_shop)
	Global.money -= new_selected_item_from_shop.cost
	update_labels()
	
	inventory.add_item(new_selected_item_from_shop)
	shop.item_bought(shop_clicked_item_id)
	
	shop.reset_items()
	for player_inventory in players_grid_container.get_children() as Array[PlayerInventory]:
		player_inventory.reset_items()
	inventory.reset_items()


func _on_shop_skip_texture_button_pressed() -> void:
	upgrades_container.hide()
	levels_container.show()


func _on_player_inventory_mouse_entered(id: PlayerType) -> void:
	# TODO
	pass


func _on_player_inventory_mouse_exited(id: PlayerType) -> void:
	# TODO
	pass


func _on_player_inventory_toggled(toggled_on: bool, id: PlayerType) -> void:
	# TODO
	pass


func _on_player_item_clicked(player_item_id: int, item_id: ItemType, player_id: PlayerType) -> void:
	# switching items not available
	var player_clicked_item_id = get_player_clicked_item_id(player_id)
	var inventory_clicked_item_id = get_inventory_clicked_item_id()
	if player_clicked_item_id == ItemType.NONE and inventory_clicked_item_id != ItemType.NONE:
		# inventory -> player
		inventory.remove_item(inventory_clicked_item_id)
		
		var selected_player = get_selected_player(player_id) as PlayerObject
		selected_player.set_item(inventory_clicked_item_id, player_item_id)
		var inventory_clicked_item = get_selected_item(inventory_clicked_item_id)
		if inventory_clicked_item and inventory_clicked_item.id != Util.ItemType.NONE:
			inventory_clicked_item.apply_to_player_object(selected_player)
		
		var player_inventory = players_grid_container.get_children().filter(func(child): return child.id == selected_player.id).front() as PlayerInventory
		assert(selected_player.items_ids.size() == 2, 'Wrong selected player items size')
		var item_1 = get_selected_item(selected_player.items_ids[0])
		var item_2 = get_selected_item(selected_player.items_ids[1])
		player_inventory.init_items(item_1, item_2)
		player_inventory.update_stats(selected_player.max_health, selected_player.move_distance, selected_player.damage, selected_player.action_type)
	elif player_clicked_item_id != ItemType.NONE and item_id == ItemType.NONE:
		# player X -> player Y
		var origin_player_inventory = players_grid_container.get_children().filter(func(child): return child.clicked_item_id == player_clicked_item_id).front() as PlayerInventory
		origin_player_inventory.remove_item(player_clicked_item_id)
		
		var origin_player = get_selected_player(origin_player_inventory.id) as PlayerObject
		var player_clicked_item = get_selected_item(player_clicked_item_id)
		if player_clicked_item and player_clicked_item.id != Util.ItemType.NONE:
			player_clicked_item.apply_to_player_object(origin_player, false)
		origin_player.unset_item(player_clicked_item_id)
		
		#assert(origin_player.items_ids.size() == 2, 'Wrong origin player items size')
		#var origin_item_1 = get_selected_item(origin_player.items_ids[0])
		#var origin_item_2 = get_selected_item(origin_player.items_ids[1])
		#origin_player_inventory.init_items(origin_item_1, origin_item_2)
		origin_player_inventory.update_stats(origin_player.max_health, origin_player.move_distance, origin_player.damage, origin_player.action_type)
	
		var target_player = get_selected_player(player_id) as PlayerObject
		target_player.set_item(player_clicked_item_id, player_item_id)
		if player_clicked_item and player_clicked_item.id != Util.ItemType.NONE:
			player_clicked_item.apply_to_player_object(target_player)
		
		var target_player_inventory = players_grid_container.get_children().filter(func(child): return child.id == target_player.id).front() as PlayerInventory
		assert(target_player.items_ids.size() == 2, 'Wrong target player items size')
		var target_item_1 = get_selected_item(target_player.items_ids[0])
		var target_item_2 = get_selected_item(target_player.items_ids[1])
		target_player_inventory.init_items(target_item_1, target_item_2)
		target_player_inventory.update_stats(target_player.max_health, target_player.move_distance, target_player.damage, target_player.action_type)
	else:
		# set items in single player container in case they were moved
		var selected_player = get_selected_player(player_id) as PlayerObject
		var player_inventory = players_grid_container.get_children().filter(func(child): return child.id == selected_player.id).front() as PlayerInventory
		selected_player.set_items(player_inventory.items_ids)
	
	on_button_disabled(shop_buy_texture_button, true)
	shop.reset_items()
	var should_highlight = player_clicked_item_id != ItemType.NONE and item_id != ItemType.NONE
	for player_inventory in players_grid_container.get_children() as Array[PlayerInventory]:
		player_inventory.reset_items(should_highlight, not should_highlight)
		if player_inventory.id != player_id:
			player_inventory.clicked_item_id = ItemType.NONE
	inventory.reset_items(should_highlight)


func _on_inventory_item_hovered(inventory_item_id: int, item_id: ItemType, is_hovered: bool) -> void:
	#print('_on_inventory_item_hovered' + str(inventory_item_id) + str(is_hovered))
	pass


func _on_inventory_item_clicked(inventory_item_id: int, item_id: ItemType) -> void:
	var player_clicked_container
	var player_clicked_item_id = get_player_clicked_item_id()
	var inventory_clicked_item_id = get_inventory_clicked_item_id()
	if player_clicked_item_id != ItemType.NONE:
		# player -> inventory
		player_clicked_container = players_grid_container.get_children().filter(func(child): return child.items_ids.has(player_clicked_item_id)).front() as PlayerInventory
		
		if inventory_clicked_item_id == ItemType.NONE:
			player_clicked_container.remove_item(player_clicked_item_id)
			
			var selected_player = get_selected_player(player_clicked_container.id) as PlayerObject
			var player_clicked_item = get_selected_item(player_clicked_item_id) as ItemObject
			if player_clicked_item and player_clicked_item.id != Util.ItemType.NONE:
				player_clicked_item.apply_to_player_object(selected_player, false)
			selected_player.unset_item(player_clicked_item_id)
			
			player_clicked_container.update_stats(selected_player.max_health, selected_player.move_distance, selected_player.damage, selected_player.action_type)
			inventory.add_item(player_clicked_item, inventory_item_id)
			inventory.reset_items(false)
	
	on_button_disabled(shop_buy_texture_button, true)
	shop.reset_items()
	for player_inventory in players_grid_container.get_children() as Array[PlayerInventory]:
		player_inventory.reset_items(inventory_clicked_item_id != ItemType.NONE)
		if player_clicked_container and player_inventory.id != player_clicked_container.id:
			player_inventory.clicked_item_id = ItemType.NONE


func _on_level_type_button_pressed(level_type: LevelType) -> void:
	selected_level_type = level_type
	
	on_button_disabled(levels_next_texture_button, not selected_level_type)


func _on_levels_next_texture_button_pressed() -> void:
	game_state_manager.get_parent().toggle_visibility(true)
	game_state_manager.init_by_level_type(selected_level_type)
	
	queue_free()
