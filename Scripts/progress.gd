extends Util

@export var player_container_scene: PackedScene

@onready var menu: Menu = $/root/Menu
@onready var game_state_manager: GameStateManager = $/root/Main/GameStateManager
@onready var upgrades_container = $CanvasLayer/PanelCenterContainer/UpgradesContainer
@onready var shop_label = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopLabel
@onready var shop_buy_button = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopButtonsHBoxContainer/ShopBuyButton
@onready var shop_skip_button = $CanvasLayer/PanelCenterContainer/UpgradesContainer/ShopContainer/ShopButtonsHBoxContainer/ShopSkipButton
@onready var players_grid_container = $CanvasLayer/PanelCenterContainer/UpgradesContainer/PlayersGridContainer
@onready var levels_container = $CanvasLayer/PanelCenterContainer/LevelsContainer
@onready var levels_next_button = $CanvasLayer/PanelCenterContainer/LevelsContainer/LevelsNextButton

var selected_upgrade_id: int
var selected_level_type: LevelType


func _ready() -> void:
	Global.engine_mode = Global.EngineMode.MENU
	Global.loot = 5
	
	if Global.loot > 0:
		upgrades_container.show()
		levels_container.hide()
	else:
		upgrades_container.hide()
		levels_container.show()
	
	shop_label.text = 'Welcome to the SHOP\nBuy upgrades and recruit new players\nMoney: ' + str(Global.money) + ' / Loot: ' + str(Global.loot)
	shop_buy_button.set_disabled(true)
	shop_skip_button.set_disabled(false)
	levels_next_button.set_disabled(true)
	
	init_ui()


func init_ui():
	for default_player_container in players_grid_container.get_children().filter(func(child): return child.is_in_group('ALWAYS_FREE')):
		default_player_container.queue_free()
	
	assert(Global.selected_players.size() > 0 and Global.selected_players.size() <= 3, 'Wrong selected players size')
	for selected_player in Global.selected_players as Array[PlayerObject]:
		assert(selected_player.id >= 0, 'Wrong selected player id')
		var player_container = player_container_scene.instantiate() as PlayerContainer
		player_container.init(selected_player.id, selected_player.max_health, selected_player.move_distance, selected_player.damage, selected_player.action_type, _on_player_texture_button_mouse_entered, _on_player_texture_button_mouse_exited, _on_player_texture_button_toggled)
		player_container.hide_stats_containers()
		players_grid_container.add_child(player_container)


func show_back() -> void:
	Global.engine_mode = Global.EngineMode.MENU
	
	toggle_visibility(true)


func _on_menu_button_pressed() -> void:
	toggle_visibility(false)
	
	menu.show_in_game_menu(self)


func _on_shop_texture_button_pressed(id: int) -> void:
	pass # Replace with function body.


func _on_shop_buy_button_pressed():
	var selected_upgrade_player = Global.selected_players.filter(func(selected_player): return selected_player.id == selected_upgrade_id).front()
	#selected_upgrade_player.damage = selected_upgrade_player.damage_upgraded
	selected_upgrade_player.is_damage_upgraded = true
	
	Global.loot -= 3
	
	upgrades_container.hide()
	levels_container.show()


func _on_shop_skip_button_pressed():
	upgrades_container.hide()
	levels_container.show()


# not used
func _on_player_texture_button_mouse_entered(id: int) -> void:
	pass


# not used
func _on_player_texture_button_mouse_exited(id: int) -> void:
	pass


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
