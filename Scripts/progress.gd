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
@onready var summary_time_value_label = $CanvasLayer/PanelCenterContainer/SummaryContainer/SummaryTimeContainer/SummaryTimeValueLabel
@onready var summary_money_value_label = $CanvasLayer/PanelCenterContainer/SummaryContainer/SummaryMoneyContainer/SummaryMoneyValueLabel

var init_manager_script: InitManager = preload('res://Scripts/init_manager.gd').new()

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
	
	init_ui()
	update_ui()


func init_ui() -> void:
	for child in players_grid_container.get_children():
		child.hide()
	
	var index = 0
	assert(Global.selected_players.size() > 0 and Global.selected_players.size() <= 3, 'Wrong selected players size')
	for player in Global.selected_players as Array[Player]:
		assert(player.id != PlayerType.NONE, 'Wrong selected player id')
		var player_inventory = players_grid_container.get_child(index) as PlayerInventory
		player_inventory.init(player, true)
		player_inventory.connect('player_inventory_mouse_entered', _on_player_inventory_mouse_entered)
		player_inventory.connect('player_inventory_mouse_exited', _on_player_inventory_mouse_exited)
		player_inventory.connect('player_inventory_toggled', _on_player_inventory_toggled)
		player_inventory.connect('item_clicked', _on_player_inventory_item_clicked)
		player_inventory.avatar_texture_button.set_disabled(true)
		#player_inventory.texture_rect.scale = Vector2(0.75, 0.75)
		player_inventory.show()
		index += 1
	assert(players_grid_container.get_child_count() >= index, 'Wrong player stats size')
	
	var available_items: Array[ItemObject] = init_manager_script.init_available_items()
	shop.init(available_items)
	shop.connect('item_hovered', _on_shop_item_hovered)
	shop.connect('item_clicked', _on_shop_item_clicked)
	
	var empty_item: ItemObject = init_manager_script.init_item(ItemType.NONE)
	inventory.init(Global.selected_items, empty_item)
	inventory.connect('item_hovered', _on_inventory_item_hovered)
	inventory.connect('item_clicked', _on_inventory_item_clicked)


func update_ui() -> void:
	shop_label.text = 'Welcome to the SHOP\nMoney: ' + str(Global.money)
	summary_time_value_label.text = str(Global.money)
	summary_money_value_label.text = str(Global.level_time)


func show_back() -> void:
	Global.engine_mode = EngineMode.MENU
	toggle_visibility(true)


func get_player_clicked_item_id(player_id: PlayerType = PlayerType.NONE) -> ItemType:
	var player_inventory = players_grid_container.get_children().filter(func(child): return child.clicked_item_id != ItemType.NONE).front() as PlayerInventory
	if player_inventory:
		return player_inventory.clicked_item_id
	
	return ItemType.NONE


func _on_menu_button_pressed() -> void:
	toggle_visibility(false)
	menu.show_in_game_menu(self)


func _on_shop_item_hovered(shop_item_texture_index: int, item_id: ItemType, is_hovered: bool) -> void:
	#print('_on_shop_item_hovered' + str(item_id) + str(is_hovered))
	pass


func _on_shop_item_clicked(shop_item_texture_index: int, item_id: ItemType) -> void:
	var shop_clicked_item_id = shop.clicked_item_id
	if shop_clicked_item_id == ItemType.NONE:
		on_button_disabled(shop_buy_texture_button, true)
	else:
		var shop_clicked_item = init_manager_script.init_item(shop_clicked_item_id)
		on_button_disabled(shop_buy_texture_button, shop_clicked_item.cost > Global.money)
	
	inventory.reset_items()
	for player_inventory in players_grid_container.get_children() as Array[PlayerInventory]:
		player_inventory.reset_items()


func _on_shop_buy_texture_button_pressed() -> void:
	on_button_disabled(shop_buy_texture_button, true)
	
	var shop_clicked_item_id = shop.clicked_item_id
	if shop_clicked_item_id == ItemType.NONE:
		return
	
	var shop_clicked_item = init_manager_script.init_item(shop_clicked_item_id)
	if shop_clicked_item.cost > Global.money:
		return
	
	shop_clicked_item.is_available = false
	Global.selected_items.push_back(shop_clicked_item)
	
	Global.money -= shop_clicked_item.cost
	update_ui()
	
	shop.buy_item(shop_clicked_item_id)
	inventory.add_item(shop_clicked_item)
	
	shop.reset_items()
	inventory.reset_items()
	for player_inventory in players_grid_container.get_children() as Array[PlayerInventory]:
		player_inventory.reset_items()


func _on_shop_skip_texture_button_pressed() -> void:
	upgrades_container.hide()
	levels_container.show()


func _on_inventory_item_hovered(inventory_item_texture_index: int, item_id: ItemType, is_hovered: bool) -> void:
	#print('_on_inventory_item_hovered' + str(inventory_item_id) + str(is_hovered))
	pass


func _on_inventory_item_clicked(inventory_item_texture_index: int, item_id: ItemType) -> void:
	var player_clicked_container
	var player_clicked_item_id = get_player_clicked_item_id()
	var inventory_clicked_item_id = inventory.clicked_item_id
	if player_clicked_item_id != ItemType.NONE:
		# player -> inventory
		player_clicked_container = players_grid_container.get_children().filter(func(child): return child.player.item_1.id == player_clicked_item_id or child.player.item_2.id == player_clicked_item_id).front() as PlayerInventory
		if inventory_clicked_item_id == ItemType.NONE:
			var selected_player = player_clicked_container.player
			assert(selected_player.item_1.id == player_clicked_item_id or selected_player.item_2.id == player_clicked_item_id, 'Player does not have item')
			if selected_player.item_1.id == player_clicked_item_id:
				selected_player.item_1 = init_manager_script.init_item(ItemType.NONE)
			elif selected_player.item_2.id == player_clicked_item_id:
				selected_player.item_2 = init_manager_script.init_item(ItemType.NONE)
			player_clicked_container.update_stats()
			
			var player_clicked_item = init_manager_script.init_item(player_clicked_item_id)
			inventory.add_item(player_clicked_item, inventory_item_texture_index)
			inventory.reset_items(false)
	
	on_button_disabled(shop_buy_texture_button, true)
	shop.reset_items()
	for player_inventory in players_grid_container.get_children() as Array[PlayerInventory]:
		player_inventory.reset_items()
		if player_clicked_container and player_inventory.player.id != player_clicked_container.player.id:
			player_inventory.clicked_item_id = ItemType.NONE


func _on_player_inventory_mouse_entered(id: PlayerType) -> void:
	# TODO
	pass


func _on_player_inventory_mouse_exited(id: PlayerType) -> void:
	# TODO
	pass


func _on_player_inventory_toggled(toggled_on: bool, id: PlayerType) -> void:
	# TODO
	pass


func _on_player_inventory_item_clicked(player_inventory_item_texture_index: int, item_id: ItemType, player_id: PlayerType) -> void:
	# switching items not available
	var player_clicked_item_id = get_player_clicked_item_id(player_id)
	var inventory_clicked_item_id = inventory.clicked_item_id
	var selected_player_inventory = players_grid_container.get_children().filter(func(child): return child.player.id == player_id).front() as PlayerInventory
	var selected_player = selected_player_inventory.player
	if player_clicked_item_id == ItemType.NONE and inventory_clicked_item_id != ItemType.NONE:
		# inventory -> player
		inventory.remove_item(inventory_clicked_item_id)
		var inventory_clicked_item = init_manager_script.init_item(inventory_clicked_item_id)
		if player_inventory_item_texture_index == 0:
			selected_player.item_1 = inventory_clicked_item
		elif player_inventory_item_texture_index == 1:
			selected_player.item_2 = inventory_clicked_item
		selected_player_inventory.update_stats()
	elif player_clicked_item_id != ItemType.NONE and item_id == ItemType.NONE:
		# player X -> player Y
		var origin_player_inventory = players_grid_container.get_children().filter(func(child): return child.clicked_item_id == player_clicked_item_id).front() as PlayerInventory
		var origin_player = origin_player_inventory.player
		if origin_player.item_1.id == player_clicked_item_id:
			origin_player.item_1 = init_manager_script.init_item(ItemType.NONE)
		elif origin_player.item_2.id == player_clicked_item_id:
			origin_player.item_2 = init_manager_script.init_item(ItemType.NONE)
		origin_player_inventory.update_stats()
	
		var player_clicked_item = init_manager_script.init_item(player_clicked_item_id)
		if player_inventory_item_texture_index == 0:
			selected_player.item_1 = player_clicked_item
		elif player_inventory_item_texture_index == 1:
			selected_player.item_2 = player_clicked_item
		selected_player_inventory.update_stats()
	else:
		# set items in single player container in case they were moved
		selected_player_inventory.update_stats()
	
	on_button_disabled(shop_buy_texture_button, true)
	shop.reset_items()
	var should_highlight = player_clicked_item_id != ItemType.NONE and item_id != ItemType.NONE
	inventory.reset_items(should_highlight)
	for player_inventory in players_grid_container.get_children() as Array[PlayerInventory]:
		if player_inventory.player.id != player_id or not should_highlight:
			player_inventory.reset_items()


func _on_level_type_texture_button_toggled(toggled_on: bool, level_type: LevelType) -> void:
	if toggled_on:
		selected_level_type = level_type
	else:
		selected_level_type = LevelType.NONE
	
	on_button_disabled(levels_next_texture_button, selected_level_type == LevelType.NONE)


func _on_levels_next_texture_button_pressed() -> void:
	game_state_manager.get_parent().toggle_visibility(true)
	game_state_manager.init_by_level_type(selected_level_type)
	
	queue_free()
