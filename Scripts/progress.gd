extends Util

@export var player_container_scene: PackedScene
@export var item_container_scene: PackedScene

@onready var menu: Menu = $/root/Menu
@onready var game_state_manager: GameStateManager = $/root/Main/GameStateManager
@onready var canvas_layer = $CanvasLayer
@onready var upgrades_container = $CanvasLayer/PanelCenterContainer/UpgradesContainer
@onready var shop_label = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopLabel
@onready var shop: Shop = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/Shop
@onready var shop_buy_button = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopButtonsHBoxContainer/ShopBuyButton
@onready var shop_skip_button = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopButtonsHBoxContainer/ShopSkipButton
@onready var inventory_label = $CanvasLayer/PanelCenterContainer/UpgradesContainer/InventoryContainer/InventoryLabel
@onready var players_grid_container = $CanvasLayer/PanelCenterContainer/UpgradesContainer/InventoryContainer/PlayersGridContainer
@onready var inventory: Inventory = $CanvasLayer/PanelCenterContainer/UpgradesContainer/InventoryContainer/Inventory
@onready var levels_container = $CanvasLayer/PanelCenterContainer/LevelsContainer
@onready var levels_next_button = $CanvasLayer/PanelCenterContainer/LevelsContainer/LevelsNextButton

var selected_level_type: LevelType = LevelType.NONE


func _ready() -> void:
	Global.engine_mode = EngineMode.MENU
	#Global.money = 5
	
	if Global.money > 0:
		upgrades_container.show()
		levels_container.hide()
	else:
		upgrades_container.hide()
		levels_container.show()
	
	shop_buy_button.set_disabled(true)
	shop_skip_button.set_disabled(false)
	inventory_label.text = 'INVENTORY'
	levels_next_button.set_disabled(true)
	
	update_labels()
	init_ui()


func init_ui() -> void:
	# shop
	shop.connect('item_hovered', _on_shop_item_hovered)
	shop.connect('item_clicked', _on_shop_item_clicked)
	
	# selected players
	for default_player_container in players_grid_container.get_children().filter(func(child): return child.is_in_group('ALWAYS_FREE')):
		default_player_container.queue_free()
	
	assert(Global.selected_players.size() > 0 and Global.selected_players.size() <= 3, 'Wrong selected players size')
	for selected_player in Global.selected_players:
		assert(selected_player.id != PlayerType.NONE, 'Wrong selected player id')
		var player_container = player_container_scene.instantiate() as PlayerContainer
		player_container.init(selected_player.id, selected_player.texture)
		player_container.init_stats(selected_player.max_health, selected_player.move_distance, selected_player.damage, selected_player.action_type)
		
		var items = [] as Array[ItemObject]
		for item_id in selected_player.items_ids:
			var item = get_item(item_id)
			items.push_back(item)
		player_container.init_items(items)
		player_container.connect('item_clicked', _on_player_item_clicked)
		players_grid_container.add_child(player_container)
	
	# inventory
	inventory.connect('item_hovered', _on_inventory_item_hovered)
	inventory.connect('item_clicked', _on_inventory_item_clicked)


func update_labels() -> void:
	shop_label.text = 'Welcome to the SHOP\nBuy upgrades and recruit new players\nMoney: ' + str(Global.money)


func show_back() -> void:
	Global.engine_mode = EngineMode.MENU
	toggle_visibility(true)


func get_shop_clicked_item_id() -> ItemType:
	return shop.clicked_item_id


func get_player_clicked_item_id(player_id: PlayerType = PlayerType.NONE) -> ItemType:
	if player_id != PlayerType.NONE:
		var player_container = players_grid_container.get_children().filter(func(child): return child.id == player_id and child.clicked_item_id != ItemType.NONE).front() as PlayerContainer
		if player_container:
			return player_container.clicked_item_id
	
	var player_container = players_grid_container.get_children().filter(func(child): return child.clicked_item_id != ItemType.NONE).front() as PlayerContainer
	if player_container:
		return player_container.clicked_item_id
	
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
		shop_buy_button.set_disabled(true)
	else:
		var selected_item_from_shop = get_item(shop_clicked_item_id)
		shop_buy_button.set_disabled(selected_item_from_shop.cost > Global.money)
	
	for player_container in players_grid_container.get_children() as Array[PlayerContainer]:
		player_container.reset_items()
	inventory.reset_items()


func _on_shop_buy_button_pressed() -> void:
	shop_buy_button.set_disabled(true)
	
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
	for player_container in players_grid_container.get_children() as Array[PlayerContainer]:
		player_container.reset_items()
	inventory.reset_items()


func _on_shop_skip_button_pressed() -> void:
	upgrades_container.hide()
	levels_container.show()


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
		
		var player_container = players_grid_container.get_children().filter(func(child): return child.id == selected_player.id).front() as PlayerContainer
		var items = [] as Array[ItemObject]
		for selected_player_item_id in selected_player.items_ids:
			var item = get_selected_item(selected_player_item_id)
			items.push_back(item)
		player_container.init_items(items)
		player_container.update_stats(selected_player.max_health, selected_player.move_distance, selected_player.damage, selected_player.action_type)
	elif player_clicked_item_id != ItemType.NONE and item_id == ItemType.NONE:
		# player X -> player Y
		var origin_player_container = players_grid_container.get_children().filter(func(child): return child.clicked_item_id == player_clicked_item_id).front() as PlayerContainer
		origin_player_container.remove_item(player_clicked_item_id)
		
		var origin_player = get_selected_player(origin_player_container.id) as PlayerObject
		var player_clicked_item = get_selected_item(player_clicked_item_id)
		if player_clicked_item and player_clicked_item.id != Util.ItemType.NONE:
			player_clicked_item.apply_to_player_object(origin_player, false)
		origin_player.unset_item(player_clicked_item_id)
		
		#var origin_items = [] as Array[ItemObject]
		#for origin_player_item_id in origin_player.items_ids:
			#var origin_item = get_selected_item(origin_player_item_id)
			#origin_items.push_back(origin_item)
		#origin_player_container.init_items(origin_items)
		origin_player_container.update_stats(origin_player.max_health, origin_player.move_distance, origin_player.damage, origin_player.action_type)
	
		var target_player = get_selected_player(player_id) as PlayerObject
		target_player.set_item(player_clicked_item_id, player_item_id)
		if player_clicked_item and player_clicked_item.id != Util.ItemType.NONE:
			player_clicked_item.apply_to_player_object(target_player)
		
		var target_player_container = players_grid_container.get_children().filter(func(child): return child.id == target_player.id).front() as PlayerContainer
		var target_items = [] as Array[ItemObject]
		for target_player_item_id in target_player.items_ids:
			var target_item = get_selected_item(target_player_item_id)
			target_items.push_back(target_item)
		target_player_container.init_items(target_items)
		target_player_container.update_stats(target_player.max_health, target_player.move_distance, target_player.damage, target_player.action_type)
	else:
		# set items in single player container in case they were moved
		var selected_player = get_selected_player(player_id) as PlayerObject
		var player_container = players_grid_container.get_children().filter(func(child): return child.id == selected_player.id).front() as PlayerContainer
		selected_player.set_items(player_container.items_ids)
	
	shop_buy_button.set_disabled(true)
	shop.reset_items()
	var should_highlight = player_clicked_item_id != ItemType.NONE and item_id != ItemType.NONE
	for player_container in players_grid_container.get_children() as Array[PlayerContainer]:
		player_container.reset_items(should_highlight, not should_highlight)
		if player_container.id != player_id:
			player_container.clicked_item_id = ItemType.NONE
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
		player_clicked_container = players_grid_container.get_children().filter(func(child): return child.items_ids.has(player_clicked_item_id)).front() as PlayerContainer
		
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
	
	shop_buy_button.set_disabled(true)
	shop.reset_items()
	for player_container in players_grid_container.get_children() as Array[PlayerContainer]:
		player_container.reset_items(inventory_clicked_item_id != ItemType.NONE)
		if player_clicked_container and player_container.id != player_clicked_container.id:
			player_container.clicked_item_id = ItemType.NONE


func _on_level_type_button_pressed(level_type: LevelType) -> void:
	selected_level_type = level_type
	
	levels_next_button.set_disabled(not selected_level_type)


func _on_levels_next_button_pressed() -> void:
	game_state_manager.get_parent().toggle_visibility(true)
	game_state_manager.init_by_level_type(selected_level_type)
	
	queue_free()
