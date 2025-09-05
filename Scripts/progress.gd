extends Util

@export var item_container_scene: PackedScene

@onready var menu: Menu								= $/root/Menu
@onready var game_state_manager: GameStateManager	= $/root/Main/GameStateManager
@onready var canvas_layer							= $CanvasLayer
@onready var upgrades_container						= $CanvasLayer/PanelCenterContainer/UpgradesContainer
@onready var shop_label								= $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopLabel
@onready var shop: Shop								= $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/Shop
@onready var shop_buy_texture_button				= $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopButtonsHBoxContainer/ShopBuyTextureButton
@onready var shop_skip_texture_button				= $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopButtonsHBoxContainer/ShopSkipTextureButton
@onready var inventory_label						= $CanvasLayer/PanelCenterContainer/UpgradesContainer/InventoryContainer/InventoryLabel
@onready var players_grid_container					= $CanvasLayer/PanelCenterContainer/UpgradesContainer/InventoryContainer/PlayersGridContainer
@onready var inventory: Inventory					= $CanvasLayer/PanelCenterContainer/UpgradesContainer/InventoryContainer/Inventory
@onready var epochs_container						= $CanvasLayer/PanelCenterContainer/EpochsContainer
@onready var epochs_next_texture_button				= $CanvasLayer/PanelCenterContainer/EpochsContainer/EpochsNextTextureButton
@onready var epoch_type_1_texture_button			= $CanvasLayer/PanelCenterContainer/EpochsContainer/EpochsGridContainer/EpochType1TextureButton
@onready var epoch_type_2_texture_button			= $CanvasLayer/PanelCenterContainer/EpochsContainer/EpochsGridContainer/EpochType2TextureButton
@onready var epoch_type_3_texture_button			= $CanvasLayer/PanelCenterContainer/EpochsContainer/EpochsGridContainer/EpochType3TextureButton
@onready var epoch_type_4_texture_button			= $CanvasLayer/PanelCenterContainer/EpochsContainer/EpochsGridContainer/EpochType4TextureButton
@onready var levels_container						= $CanvasLayer/PanelCenterContainer/LevelsContainer
@onready var levels_next_texture_button				= $CanvasLayer/PanelCenterContainer/LevelsContainer/LevelsNextTextureButton
@onready var summary_container						= $CanvasLayer/PanelCenterContainer/SummaryContainer
@onready var summary_time_value_label				= $CanvasLayer/PanelCenterContainer/SummaryContainer/SummaryTimeContainer/SummaryTimeValueLabel
@onready var summary_money_value_label				= $CanvasLayer/PanelCenterContainer/SummaryContainer/SummaryMoneyContainer/SummaryMoneyValueLabel
@onready var summary_next_texture_button			= $CanvasLayer/PanelCenterContainer/SummaryContainer/SummaryNextTextureButton

var init_manager_script: InitManager = preload('res://Scripts/init_manager.gd').new()

var selected_level_type: LevelType = LevelType.NONE


func _ready() -> void:
	Global.engine_mode = EngineMode.MENU
	
	epoch_type_1_texture_button.connect('toggled', _on_epoch_type_texture_button_toggled.bind(0))
	epoch_type_2_texture_button.connect('toggled', _on_epoch_type_texture_button_toggled.bind(1))
	epoch_type_3_texture_button.connect('toggled', _on_epoch_type_texture_button_toggled.bind(2))
	epoch_type_4_texture_button.connect('toggled', _on_epoch_type_texture_button_toggled.bind(3))
	summary_next_texture_button.connect('pressed', _on_summary_next_texture_button_pressed)
	
	# FIXME better way of controlling which screen to show
	if Global.save.selected_epoch == Util.EpochType.NONE:
		# first time starting
		go_to_epochs()
	else:
		# level ended
		go_to_summary()
	
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
	assert(Global.save.selected_player_ids.size() > 0 and Global.save.selected_player_ids.size() <= 3, 'Wrong selected player ids size')
	for player_id in Global.save.selected_player_ids:
		assert(player_id != PlayerType.NONE, 'Wrong selected player id')
		var player = Player.new()
		init_manager_script.init_player(player, player_id)
		for bought_item_id in Global.save.bought_item_ids:
			# is assigned to player
			if Global.save.bought_item_ids[bought_item_id] == player_id:
				if not player.item_1 or player.item_1.id == ItemType.NONE:
					player.item_1 = init_manager_script.init_item(bought_item_id)
				elif not player.item_2 or player.item_2.id == ItemType.NONE:
					player.item_2 = init_manager_script.init_item(bought_item_id)
		
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
	
	var available_items = init_manager_script.init_available_items()
	shop.init(available_items)
	shop.connect('item_hovered', _on_shop_item_hovered)
	shop.connect('item_clicked', _on_shop_item_clicked)
	
	var empty_item = init_manager_script.init_item(ItemType.NONE)
	var bought_items = [] as Array[ItemObject]
	for bought_item_id in Global.save.bought_item_ids:
		# is in inventory
		if Global.save.bought_item_ids[bought_item_id] == PlayerType.NONE:
			var bought_item = init_manager_script.init_item(bought_item_id)
			bought_items.append(bought_item)
	inventory.init(bought_items, empty_item)
	inventory.connect('item_hovered', _on_inventory_item_hovered)
	inventory.connect('item_clicked', _on_inventory_item_clicked)


func update_ui() -> void:
	shop_label.text = 'Welcome to the SHOP\nMoney: ' + str(Global.save.money)
	summary_time_value_label.text = str(Global.save.money)
	summary_money_value_label.text = str(Global.save.level_time)


func show_back() -> void:
	Global.engine_mode = EngineMode.MENU
	toggle_visibility(true)


func get_player_clicked_item_id() -> ItemType:
	var player_inventory = players_grid_container.get_children().filter(func(child): return child.clicked_item_id != ItemType.NONE).front() as PlayerInventory
	if player_inventory:
		return player_inventory.clicked_item_id
	
	return ItemType.NONE


func go_to_upgrades() -> void:
	upgrades_container.show()
	epochs_container.hide()
	levels_container.hide()
	summary_container.hide()


func go_to_epochs() -> void:
	upgrades_container.hide()
	epochs_container.show()
	levels_container.hide()
	summary_container.hide()


func go_to_levels() -> void:
	upgrades_container.hide()
	epochs_container.hide()
	levels_container.show()
	summary_container.hide()


func go_to_summary() -> void:
	upgrades_container.hide()
	epochs_container.hide()
	levels_container.hide()
	summary_container.show()


func go_to_main() -> void:
	game_state_manager.get_parent().toggle_visibility(true)
	game_state_manager.init_by_level_type(selected_level_type)
	
	queue_free()


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
		on_button_disabled(shop_buy_texture_button, shop_clicked_item.cost > Global.save.money)
	
	inventory.reset_items()
	for player_inventory in players_grid_container.get_children() as Array[PlayerInventory]:
		player_inventory.reset_items()


func _on_shop_buy_texture_button_pressed() -> void:
	on_button_disabled(shop_buy_texture_button, true)
	
	var shop_clicked_item_id = shop.clicked_item_id
	if shop_clicked_item_id == ItemType.NONE:
		return
	
	var shop_clicked_item = init_manager_script.init_item(shop_clicked_item_id)
	if shop_clicked_item.cost > Global.save.money:
		return
	
	shop_clicked_item.is_available = false
	# item bought but not yet assigned
	Global.save.bought_item_ids[shop_clicked_item.id] = PlayerType.NONE
	
	Global.save.money -= shop_clicked_item.cost
	update_ui()
	
	shop.buy_item(shop_clicked_item_id)
	inventory.add_item(shop_clicked_item)
	
	shop.reset_items()
	inventory.reset_items()
	for player_inventory in players_grid_container.get_children() as Array[PlayerInventory]:
		player_inventory.reset_items()


func _on_shop_skip_texture_button_pressed() -> void:
	go_to_main()


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
			
			Global.save.bought_item_ids[player_clicked_item_id] = PlayerType.NONE
	
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
	var player_clicked_item_id = get_player_clicked_item_id()
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
		
		Global.save.bought_item_ids[inventory_clicked_item_id] = selected_player.id
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
		
		Global.save.bought_item_ids[player_clicked_item_id] = selected_player.id
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


func _on_epochs_next_texture_button_pressed() -> void:
	go_to_levels()


func _on_epoch_type_texture_button_toggled(toggled_on: bool, epoch_type: EpochType) -> void:
	assert(Global.save.unlocked_epoch_ids.has(epoch_type), 'Selected epoch not unlocked')
	print('Selected epoch: ' + str(EpochType.keys()[epoch_type]))
	Global.save.selected_epoch = epoch_type


func _on_level_type_texture_button_toggled(toggled_on: bool, level_type: LevelType) -> void:
	if toggled_on:
		selected_level_type = level_type
	else:
		selected_level_type = LevelType.NONE
	
	on_button_disabled(levels_next_texture_button, selected_level_type == LevelType.NONE)


func _on_levels_next_texture_button_pressed() -> void:
	go_to_upgrades()


func _on_summary_next_texture_button_pressed() -> void:
	go_to_levels()
