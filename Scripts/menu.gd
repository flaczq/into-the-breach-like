extends Util

class_name Menu

@export var main_scene: PackedScene
@export var editor_scene: PackedScene
@export var cutscenes_scene: PackedScene

@onready var main_menu_container = $CanvasLayer/PanelCenterContainer/MainMenuContainer
@onready var editor_texture_button = $CanvasLayer/PanelCenterContainer/MainMenuContainer/EditorTextureButton
@onready var tutorial_check_button = $CanvasLayer/PanelCenterContainer/MainMenuContainer/TutorialCheckButton
@onready var in_game_menu_container = $CanvasLayer/PanelCenterContainer/InGameMenuContainer
@onready var options_container = $CanvasLayer/PanelCenterContainer/OptionsContainer
@onready var language_option_button = $CanvasLayer/PanelCenterContainer/OptionsContainer/LanguageHBoxContainer/LanguageOptionButton
@onready var camera_position_option_button = $CanvasLayer/PanelCenterContainer/OptionsContainer/CameraPositionHBoxContainer/CameraPositionOptionButton
@onready var aa_check_box = $CanvasLayer/PanelCenterContainer/OptionsContainer/AAHBoxContainer/AACheckBox
@onready var players_container = $CanvasLayer/PanelCenterContainer/PlayersContainer
@onready var players_grid_container = $CanvasLayer/PanelCenterContainer/PlayersContainer/PlayersGridContainer
@onready var next_texture_button = $CanvasLayer/PanelCenterContainer/PlayersContainer/NextTextureButton
@onready var right_container = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer
@onready var version_label = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightBottomContainer/VersionLabel

# FIXME change when steam page is up
const STEAM_APP_ID = 480; # deprecated

var init_manager_script: InitManager = preload('res://Scripts/init_manager.gd').new()

var playable_players: Array[Player]
var last_screen: Util


func _ready() -> void:
	Global.engine_mode = EngineMode.MENU
	
	TranslationServer.set_locale('en')
	version_label.text = 'version: ' + ProjectSettings.get_setting('application/config/version') + '-' + Time.get_date_string_from_system().replace('-', '')
	
	tutorial_check_button.set_pressed(Global.tutorial)
	_on_tutorial_check_button_toggled(Global.tutorial)
	
	language_option_button.select(Global.language)
	_on_language_option_button_item_selected(Global.language)
	
	camera_position_option_button.select(Global.camera_position)
	_on_camera_position_option_button_item_selected(Global.camera_position)
	
	aa_check_box.set_pressed(Global.antialiasing)
	_on_aa_check_box_toggled(Global.antialiasing)
	
	on_button_disabled(next_texture_button, true)
	
	right_container.hide()
	main_menu_container.show()
	if Global.build_mode == BuildMode.DEBUG:
		editor_texture_button.show()
	else:
		editor_texture_button.hide()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.hide()
	
	init_steam()
	#init_all_things()
	init_ui()


func _input(event: InputEvent) -> void:
	if Global.engine_mode != EngineMode.MENU:
		return


func show_in_game_menu(new_last_screen: Util) -> void:
	Global.engine_mode = EngineMode.MENU
	
	last_screen = new_last_screen
	
	right_container.hide()
	main_menu_container.hide()
	in_game_menu_container.show()
	options_container.hide()
	players_container.hide()
	
	camera_position_option_button.select(Global.camera_position)
	_on_camera_position_option_button_item_selected(Global.camera_position)
	
	toggle_visibility(true)


func show_main() -> void:
	toggle_visibility(false)
	
	add_sibling(main_scene.instantiate())


func show_cutscenes() -> void:
	toggle_visibility(false)
	
	var cutscenes = cutscenes_scene.instantiate() as Cutscenes
	add_sibling(cutscenes)
	cutscenes.init(1)


func show_players_selection() -> void:
	#Global.selected_items = []
	Global.selected_players = []
	Global.selected_items = []
	Global.played_maps_ids = []
	
	for player_inventory in players_grid_container.get_children():
		var player_texture_button = player_inventory.avatar_texture_button
		player_texture_button.set_pressed_no_signal(false)
		#player_texture_button.modulate.a = 0.5
	
	right_container.show()
	main_menu_container.hide()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.show()


func init_steam() -> void:
	Steam.steamInitEx()
	if Steam.isSteamRunning():
		print('Steam is running for username: ' + Steam.getPersonaName())
	else:
		print('Steam is not running')


#func init_all_things() -> void:
	#ACTIONS
	#var all_actions = init_manager_script.init_all_actions()
	#Global.all_actions.append_array(all_actions)
	
	#ITEMS
	## TODO include in save
	#var all_items = init_manager_script.init_all_items()
	#Global.all_items.append_array(all_items)
	
	#PLAYERS
	## TODO include in save
	#var all_players = init_manager_script.init_all_players()
	#Global.all_players.append_array(all_players)
	#assert(Global.all_players.all(func(player): return player.state_types.is_empty() and player.items_ids.all(func(item): return item == ItemType.NONE)), 'Wrong default values for all players')
	
	#ENEMIES
	#var all_enemies = init_manager_script.init_all_enemies()
	#Global.all_enemies.append_array(all_enemies)
	
	#CIVILIANS
	#var all_civilians = init_manager_script.init_all_civilians()
	#Global.all_civilians.append_array(all_civilians)


func init_ui() -> void:
	for child in players_grid_container.get_children():
		child.hide()
	
	var index = 0
	playable_players = init_manager_script.init_playable_players()
	assert(playable_players.size() >= 3, 'Wrong all players size')
	for player in playable_players as Array[Player]:
		assert(player.id != PlayerType.NONE, 'Wrong player id')
		var player_inventory = players_grid_container.get_child(index) as PlayerInventory
		player_inventory.init(player)
		player_inventory.connect('player_inventory_mouse_entered', _on_player_inventory_mouse_entered)
		player_inventory.connect('player_inventory_mouse_exited', _on_player_inventory_mouse_exited)
		player_inventory.connect('player_inventory_toggled', _on_player_inventory_toggled)
		#player_inventory.texture_rect.scale = Vector2(0.75, 0.75)
		player_inventory.show()
		index += 1
	assert(players_grid_container.get_child_count() >= index, 'Wrong player inventory size')


func get_player_inventory_by_id(id: PlayerType) -> PlayerInventory:
	return players_grid_container.get_children().filter(func(child): return child.player.id == id).front() as PlayerInventory


func _on_editor_texture_button_pressed() -> void:
	toggle_visibility(false)
	
	add_sibling(editor_scene.instantiate())


func _on_start_texture_button_pressed() -> void:
	if Global.tutorial:
		var tutorial_player_object = init_manager_script.init_tutorial_player()
		Global.selected_players.push_back(tutorial_player_object)
		
		show_main()
	else:
		show_cutscenes()


func _on_tutorial_check_button_toggled(toggled_on: bool) -> void:
	Global.tutorial = toggled_on


func _on_options_texture_button_pressed() -> void:
	right_container.hide()
	main_menu_container.hide()
	in_game_menu_container.hide()
	options_container.show()
	players_container.hide()


func _on_wishlist_texture_button_pressed() -> void:
	var app_id = (Steam.getAppID()) if (Steam.getAppID() > 0) else (STEAM_APP_ID)
	#Not necessary if configuration is in project settings
	#OS.set_environment('SteamAppID', str(app_id))
	#OS.set_environment('SteamGameID', str(app_id))
	print('Using ' + (('steam running game id') if (Steam.getAppID() > 0) else ('STEAM_APP_ID')) + ': ' + str(app_id))
	if Steam.isSteamRunning():
		Steam.activateGameOverlayToStore(app_id)
		print('Opened game page via steam overlay')
	else:
		var steam_open = OS.shell_open('steam://advertise/' + str(app_id));
		if steam_open == OK:
			print('Opened game page via shell command, which should open steam anyway...')
		else:
			print('Opened game page via browser')
			OS.shell_open('https://store.steampowered.com/app/' + str(app_id))


func _on_exit_texture_button_pressed() -> void:
	# TODO prompt for confirmation and save
	get_tree().quit()


func _on_resume_texture_button_pressed() -> void:
	toggle_visibility(false)
	
	last_screen.show_back()
	last_screen = null


func _on_main_menu_texture_button_pressed() -> void:
	Global.engine_mode = EngineMode.MENU
	
	right_container.hide()
	main_menu_container.show()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.hide()
	on_button_disabled(next_texture_button, true)
	
	toggle_visibility(true)
	
	for child_to_queue in get_tree().root.get_children().filter(func(child): return is_instance_valid(child) and not child.is_queued_for_deletion() and not child.is_in_group('NEVER_FREE')):
		child_to_queue.queue_free()


func _on_back_texture_button_pressed() -> void:
	right_container.hide()
	
	if get_node_or_null('/root/Main'):
		# in game
		main_menu_container.hide()
		in_game_menu_container.show()
	else:
		main_menu_container.show()
		in_game_menu_container.hide()
	
	options_container.hide()
	players_container.hide()


func _on_language_option_button_item_selected(index: int) -> void:
	Global.language = index
	
	TranslationServer.set_locale(Language.keys()[Global.language].to_lower())


func _on_camera_position_option_button_item_selected(index):
	Global.camera_position = index


func _on_aa_check_box_toggled(toggled_on: bool) -> void:
	Global.antialiasing = toggled_on
	
	if Global.antialiasing:
		RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_8X)
	else:
		RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_DISABLED)


func _on_next_texture_button_pressed() -> void:
	show_main()


func _on_player_inventory_mouse_entered(id: PlayerType) -> void:
	pass


func _on_player_inventory_mouse_exited(id: PlayerType) -> void:
	pass


func _on_player_inventory_toggled(toggled_on: bool, id: PlayerType) -> void:
	#var player_inventory = get_player_inventory_by_id(id)
	#var player_inventory_avatar = player_inventory.avatar_texture_button
	#player_inventory_avatar.modulate.a = (1.0) if (toggled_on) else (0.5)
	
	if toggled_on:
		var selected_player = playable_players.filter(func(playable_player): return playable_player.id == id).front()
		Global.selected_players.push_back(selected_player)
	else:
		Global.selected_players = Global.selected_players.filter(func(selected_player): return selected_player.id != id)
	
	on_button_disabled(next_texture_button, Global.selected_players.size() != 3)
	assert(Global.selected_players.size() <= 3, 'Too many selected players')
