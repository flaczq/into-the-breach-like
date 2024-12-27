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
@onready var levels_container = $CanvasLayer/PanelCenterContainer/LevelsContainer
@onready var levels_next_button = $CanvasLayer/PanelCenterContainer/LevelsContainer/LevelsNextButton

var selected_item_id: int = -1
var selected_level_type: LevelType


func _ready() -> void:
	Global.engine_mode = Global.EngineMode.MENU
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
	
	assert(Global.available_items.size() > 0, 'Wrong available items size')
	for available_item in Global.available_items as Array[ItemObject]:
		assert(available_item.id >= 0, 'Wrong available item id')
		var item_container = item_container_scene.instantiate() as ItemContainer
		item_container.init(available_item, Callable(), Callable(), _on_item_texture_button_toggled)
		var item_texture_button = item_container.find_child('ItemTextureButton')
		item_texture_button.set_disabled(Global.money < available_item.cost)
		item_texture_button.modulate.a = 0.5
		shop_grid_container.add_child(item_container)
	
	# Init UI for selected players
	for default_player_container in players_grid_container.get_children().filter(func(child): return child.is_in_group('ALWAYS_FREE')):
		default_player_container.queue_free()
	
	assert(Global.selected_players.size() > 0 and Global.selected_players.size() <= 3, 'Wrong selected players size')
	for selected_player in Global.selected_players as Array[PlayerObject]:
		assert(selected_player.id >= 0, 'Wrong selected player id')
		var player_container = player_container_scene.instantiate() as PlayerContainer
		player_container.init(selected_player.id, Callable(), Callable(), _on_player_texture_button_toggled)
		
		var item_objects = [] as Array[ItemObject]
		for item_id in selected_player.item_ids:
			var item_object = Global.available_items.filter(func(available_item): return available_item.id == item_id).front()
			item_objects.push_back(item_object)
		
		player_container.init_items(item_objects)
		players_grid_container.add_child(player_container)


func update_labels() -> void:
	shop_label.text = 'Welcome to the SHOP\nBuy upgrades and recruit new players\nMoney: ' + str(Global.money)


func show_back() -> void:
	Global.engine_mode = Global.EngineMode.MENU
	
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


func _on_shop_buy_button_pressed():
	var selected_item = Global.available_items.filter(func(available_item): return available_item.id == selected_item_id).front()
	Global.selected_items.push_back(selected_item)
	
	Global.money -= selected_item.cost
	update_labels()
	
	for child in shop_grid_container.get_children():
		var item_texture_button = child.find_child('ItemTextureButton')
		if child.id == selected_item_id:
			item_texture_button.set_pressed_no_signal(false)
			on_button_disabled(item_texture_button, true)
			item_texture_button.flip_v = true
		else:
			var available_item = Global.available_items.filter(func(available_item): return available_item.id == child.id).front()
			item_texture_button.set_disabled(Global.money < available_item.cost)
			item_texture_button.modulate.a = 0.5


func _on_shop_skip_button_pressed():
	upgrades_container.hide()
	levels_container.show()


func _on_player_texture_button_toggled(toggled_on: bool, id: int) -> void:
	# TODO FIXME
	var player_container = players_grid_container.get_children().filter(func(child): return child.id == id).front()
	var player_texture_button = player_container.find_child('PlayerTextureButton')
	player_texture_button.modulate.a = (1.0) if (toggled_on) else (0.5)


func _on_level_type_button_pressed(level_type: LevelType) -> void:
	selected_level_type = level_type
	
	levels_next_button.set_disabled(not selected_level_type)


func _on_levels_next_button_pressed():
	game_state_manager.get_parent().toggle_visibility(true)
	game_state_manager.init_by_level_type(selected_level_type)
	
	queue_free()
