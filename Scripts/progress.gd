extends Util

@export var player_container_scene: PackedScene
@export var item_container_scene: PackedScene

@onready var menu: Menu = $/root/Menu
@onready var game_state_manager: GameStateManager = $/root/Main/GameStateManager
@onready var upgrades_container = $CanvasLayer/PanelCenterContainer/UpgradesContainer
@onready var shop_label = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopLabel
@onready var shop_grid_container = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopGridContainer
@onready var shop_buy_button = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopButtonsHBoxContainer/ShopBuyButton
@onready var shop_skip_button = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopButtonsHBoxContainer/ShopSkipButton
@onready var inventory_label = $CanvasLayer/PanelCenterContainer/UpgradesContainer/InventoryContainer/InventoryLabel
@onready var players_grid_container = $CanvasLayer/PanelCenterContainer/UpgradesContainer/InventoryContainer/PlayersGridContainer
@onready var inventory: Inventory = $CanvasLayer/PanelCenterContainer/UpgradesContainer/InventoryContainer/Inventory
@onready var levels_container = $CanvasLayer/PanelCenterContainer/LevelsContainer
@onready var levels_next_button = $CanvasLayer/PanelCenterContainer/LevelsContainer/LevelsNextButton

var selected_item_id: int = -1
var selected_level_type: LevelType


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
	# Init UI for all available items
	for default_item_container in shop_grid_container.get_children().filter(func(child): return child.is_in_group('ALWAYS_FREE')):
		default_item_container.queue_free()
	
	assert(Global.all_items.size() > 0, 'Wrong available items size')
	for item in Global.all_items as Array[ItemObject]:
		assert(item.id >= 0, 'Wrong available item id')
		var item_container = item_container_scene.instantiate() as ItemContainer
		item_container.init(item, Callable(), Callable(), _on_item_texture_button_toggled)
		var item_texture_button = item_container.find_child('ItemTextureButton')
		item_texture_button.set_disabled(Global.money < item.cost)
		item_texture_button.modulate.a = 0.5
		shop_grid_container.add_child(item_container)
	
	# Init UI for selected players
	for default_player_container in players_grid_container.get_children().filter(func(child): return child.is_in_group('ALWAYS_FREE')):
		default_player_container.queue_free()
	
	assert(Global.selected_players_ids.size() > 0 and Global.selected_players_ids.size() <= 3, 'Wrong selected players ids size')
	for selected_player_id in Global.selected_players_ids:
		var selected_player = Global.all_players.filter(func(player): return player.id == selected_player_id).front() as PlayerObject
		assert(selected_player.id >= 0, 'Wrong selected player id')
		var player_container = player_container_scene.instantiate() as PlayerContainer
		player_container.init(selected_player.id, selected_player.texture, Callable(), Callable(), _on_player_texture_button_toggled)
		
		var items = [] as Array[ItemObject]
		for item_id in selected_player.items_ids:
			var item = Global.all_items.filter(func(item): return item.id == item_id).front()
			items.push_back(item)
		
		player_container.init_stats(selected_player.max_health, selected_player.move_distance, selected_player.damage, selected_player.action_type)
		player_container.init_items(items)
		players_grid_container.add_child(player_container)


func update_labels() -> void:
	shop_label.text = 'Welcome to the SHOP\nBuy upgrades and recruit new players\nMoney: ' + str(Global.money)


func show_back() -> void:
	Global.engine_mode = EngineMode.MENU
	
	toggle_visibility(true)


func _on_menu_button_pressed() -> void:
	toggle_visibility(false)
	
	menu.show_in_game_menu(self)


func _on_item_texture_button_toggled(toggled_on: bool, id: int) -> void:
	for child in shop_grid_container.get_children():
		var item_texture_button = child.find_child('ItemTextureButton')
		if child.id == id:
			item_texture_button.set_pressed_no_signal(toggled_on)
			item_texture_button.modulate.a = (1.0) if (toggled_on) else (0.5)
		else:
			item_texture_button.set_pressed_no_signal(false)
			item_texture_button.modulate.a = 0.5
	
	selected_item_id = (id) if (toggled_on) else (-1)
	
	shop_buy_button.set_disabled(not toggled_on)


func _on_shop_buy_button_pressed() -> void:
	shop_buy_button.set_disabled(true)
	
	var selected_item = Global.all_items.filter(func(item): return item.id == selected_item_id).front()
	inventory.add_item(selected_item)
	
	Global.money -= selected_item.cost
	update_labels()
	
	for child in shop_grid_container.get_children():
		var item_texture_button = child.find_child('ItemTextureButton')
		if child.id == selected_item_id:
			item_texture_button.set_pressed_no_signal(false)
			on_button_disabled(item_texture_button, true)
			item_texture_button.flip_v = true
		else:
			var item = Global.all_items.filter(func(item): return item.id == child.id).front()
			item_texture_button.set_disabled(Global.money < item.cost)
			item_texture_button.modulate.a = 0.5


func _on_shop_skip_button_pressed() -> void:
	upgrades_container.hide()
	levels_container.show()


func _on_player_texture_button_toggled(toggled_on: bool, id: int) -> void:
	pass
	#for child in players_grid_container.get_children():
		#var player_texture_button = child.find_child('PlayerTextureButton')
		#if child.id == id:
			#player_texture_button.set_pressed_no_signal(toggled_on)
			#player_texture_button.modulate.a = (1.0) if (toggled_on) else (0.5)
		#else:
			#player_texture_button.set_pressed_no_signal(false)
			#player_texture_button.modulate.a = 0.5


func _on_level_type_button_pressed(level_type: LevelType) -> void:
	selected_level_type = level_type
	
	levels_next_button.set_disabled(not selected_level_type)


func _on_levels_next_button_pressed() -> void:
	game_state_manager.get_parent().toggle_visibility(true)
	game_state_manager.init_by_level_type(selected_level_type)
	
	queue_free()
