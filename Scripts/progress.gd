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

var selected_item_id_from_shop: ItemType = ItemType.NONE
var selected_item_id_from_inventory: ItemType = ItemType.NONE
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
	
	assert(Global.selected_players_ids.size() > 0 and Global.selected_players_ids.size() <= 3, 'Wrong selected players ids size')
	for selected_player_id in Global.selected_players_ids:
		var selected_player = get_player(selected_player_id) as PlayerObject
		assert(selected_player.id >= 0, 'Wrong selected player id')
		var player_container = player_container_scene.instantiate() as PlayerContainer
		player_container.init(selected_player.id, selected_player.texture)
		player_container.init_stats(selected_player.max_health, selected_player.move_distance, selected_player.damage, selected_player.action_type)
		
		var items = [] as Array[ItemObject]
		for item_id in selected_player.items_ids:
			var item = get_item(item_id)
			if item:
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


func _on_menu_button_pressed() -> void:
	toggle_visibility(false)
	
	menu.show_in_game_menu(self)


func _on_shop_item_hovered(shop_item_id: int, item_id: ItemType, is_hovered: bool) -> void:
	#print('_on_shop_item_hovered' + str(item_id) + str(is_hovered))
	pass


func _on_shop_item_clicked(shop_item_id: int, item_id: ItemType) -> void:
	selected_item_id_from_shop = item_id
	
	if selected_item_id_from_shop == ItemType.NONE:
		shop_buy_button.set_disabled(true)
	else:
		var selected_item_from_shop = get_item(selected_item_id_from_shop)
		shop_buy_button.set_disabled(selected_item_from_shop.cost > Global.money)
	
	for player_container in players_grid_container.get_children() as Array[PlayerContainer]:
		player_container.toggle_empty_items(false)
	
	inventory.reset_items_click()


func _on_shop_buy_button_pressed() -> void:
	shop_buy_button.set_disabled(true)
	
	if selected_item_id_from_shop == ItemType.NONE:
		return
	
	var selected_item_from_shop = get_item(selected_item_id_from_shop)
	if selected_item_from_shop.cost > Global.money:
		return
	
	inventory.add_item(selected_item_from_shop)
	shop.item_bought(selected_item_id_from_shop)
	
	Global.money -= selected_item_from_shop.cost
	update_labels()
	
	selected_item_id_from_shop = ItemType.NONE


func _on_shop_skip_button_pressed() -> void:
	upgrades_container.hide()
	levels_container.show()


func _on_player_item_clicked(player_item_id: int, item_id: ItemType, player_id: int) -> void:
	if selected_item_id_from_inventory == ItemType.NONE:
		return
	
	if item_id != ItemType.NONE:
		# switching items not available
		pass
	else:
		# move item outside of inventory
		var selected_item_from_inventory = get_item(selected_item_id_from_inventory) as ItemObject
		inventory.remove_item(selected_item_from_inventory)
		
		var selected_player = get_player(player_id) as PlayerObject
		selected_player.add_item(selected_item_id_from_inventory)
		
		var items = [] as Array[ItemObject]
		for selected_player_item_id in selected_player.items_ids:
			var item = get_item(selected_player_item_id)
			if item:
				items.push_back(item)
		
		var player_container = players_grid_container.get_children().filter(func(child): return child.id == selected_player.id).front()
		player_container.init_items(items)
	
	selected_item_id_from_inventory = ItemType.NONE
	
	for player_container in players_grid_container.get_children() as Array[PlayerContainer]:
		player_container.toggle_empty_items(false)
	
	inventory.reset_items_click()


func _on_inventory_item_hovered(inventory_item_id: int, item_id: ItemType, is_hovered: bool) -> void:
	#print('_on_inventory_item_hovered' + str(inventory_item_id) + str(is_hovered))
	pass


func _on_inventory_item_clicked(inventory_item_id: int, item_id: ItemType) -> void:
	selected_item_id_from_inventory = item_id
	
	for player_container in players_grid_container.get_children() as Array[PlayerContainer]:
		player_container.toggle_empty_items(selected_item_id_from_inventory != ItemType.NONE)


func _on_level_type_button_pressed(level_type: LevelType) -> void:
	selected_level_type = level_type
	
	levels_next_button.set_disabled(not selected_level_type)


func _on_levels_next_button_pressed() -> void:
	game_state_manager.get_parent().toggle_visibility(true)
	game_state_manager.init_by_level_type(selected_level_type)
	
	queue_free()
