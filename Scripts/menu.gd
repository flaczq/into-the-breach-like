extends Util

class_name Menu

@export var main_scene: PackedScene
@export var editor_scene: PackedScene
@export var cutscenes_scene: PackedScene
@export var player_container_scene: PackedScene

@onready var main_menu_container = $CanvasLayer/PanelCenterContainer/MainMenuContainer
@onready var editor_button = $CanvasLayer/PanelCenterContainer/MainMenuContainer/EditorButton
@onready var tutorial_check_button = $CanvasLayer/PanelCenterContainer/MainMenuContainer/TutorialCheckButton
@onready var in_game_menu_container = $CanvasLayer/PanelCenterContainer/InGameMenuContainer
@onready var options_container = $CanvasLayer/PanelCenterContainer/OptionsContainer
@onready var language_option_button = $CanvasLayer/PanelCenterContainer/OptionsContainer/LanguageHBoxContainer/LanguageOptionButton
@onready var camera_position_option_button = $CanvasLayer/PanelCenterContainer/OptionsContainer/CameraPositionHBoxContainer/CameraPositionOptionButton
@onready var aa_check_box = $CanvasLayer/PanelCenterContainer/OptionsContainer/AAHBoxContainer/AACheckBox
@onready var players_container = $CanvasLayer/PanelCenterContainer/PlayersContainer
@onready var players_grid_container = $CanvasLayer/PanelCenterContainer/PlayersContainer/PlayersGridContainer
@onready var next_button = $CanvasLayer/PanelCenterContainer/PlayersContainer/NextButton
@onready var right_container = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer
@onready var version_label = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightBottomContainer/VersionLabel

var init_manager_script: InitManager = preload('res://Scripts/init_manager.gd').new()

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
	
	next_button.set_disabled(true)
	
	right_container.hide()
	main_menu_container.show()
	if Global.build_mode == BuildMode.DEBUG:
		editor_button.show()
	else:
		editor_button.hide()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.hide()
	
	init_all_players()
	init_all_items()
	
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
	Global.selected_items_ids = []
	Global.selected_players_ids = []
	Global.played_maps_ids = []
	
	for player_container in players_grid_container.get_children():
		# FIXME disable state
		var player_texture_button = player_container.find_child('PlayerTextureButton')
		player_texture_button.set_pressed_no_signal(false)
		player_texture_button.modulate.a = 0.5
	
	right_container.show()
	main_menu_container.hide()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.show()


func init_all_players() -> void:
	# FIXME include in save
	var all_players = init_manager_script.init_all_players()
	Global.all_players.append_array(all_players)


func init_all_items() -> void:
	# FIXME include in save
	var all_items = init_manager_script.init_all_items()
	Global.all_items.append_array(all_items)


func init_ui() -> void:
	for default_player_container in players_grid_container.get_children().filter(func(child): return child.is_in_group('ALWAYS_FREE')):
		default_player_container.queue_free()
	
	assert(Global.all_players.size() >= 3, 'Wrong all players size')
	for player in Global.all_players as Array[PlayerObject]:
		assert(player.id >= 0, 'Wrong player id')
		var player_container = player_container_scene.instantiate() as PlayerContainer
		player_container.init(player.id, player.texture, Callable(), Callable(), _on_player_texture_button_toggled)
		player_container.init_stats(player.max_health, player.move_distance, player.damage, player.action_type)
		var player_texture_button = player_container.find_child('PlayerTextureButton')
		player_texture_button.modulate.a = 0.5
		players_grid_container.add_child(player_container)


func _on_editor_button_pressed() -> void:
	toggle_visibility(false)
	
	add_sibling(editor_scene.instantiate())


func _on_start_button_pressed() -> void:
	if Global.tutorial:
		show_main()
	else:
		show_cutscenes()


func _on_tutorial_check_button_toggled(toggled_on: bool) -> void:
	Global.tutorial = toggled_on


func _on_options_button_pressed() -> void:
	right_container.hide()
	main_menu_container.hide()
	in_game_menu_container.hide()
	options_container.show()
	players_container.hide()


func _on_exit_button_pressed() -> void:
	# TODO prompt for confirmation and save
	get_tree().quit()


func _on_resume_button_pressed() -> void:
	toggle_visibility(false)
	
	last_screen.show_back()
	last_screen = null


func _on_save_button_pressed() -> void:
	# TODO
	print('saved')


func _on_main_menu_button_pressed() -> void:
	Global.engine_mode = EngineMode.MENU
	
	right_container.hide()
	main_menu_container.show()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.hide()
	next_button.set_disabled(true)
	
	toggle_visibility(true)
	
	for child_to_queue in get_tree().root.get_children().filter(func(child): return is_instance_valid(child) and not child.is_queued_for_deletion() and not child.is_in_group('NEVER_FREE')):
		child_to_queue.queue_free()


func _on_back_button_pressed() -> void:
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


func _on_next_button_pressed() -> void:
	show_main()


func _on_player_texture_button_toggled(toggled_on: bool, id: int) -> void:
	var player_container = players_grid_container.get_children().filter(func(child): return child.id == id).front()
	var player_texture_button = player_container.find_child('PlayerTextureButton')
	player_texture_button.modulate.a = (1.0) if (toggled_on) else (0.5)
	
	if toggled_on:
		Global.selected_players_ids.push_back(id)
	else:
		Global.selected_players_ids.erase(id)
	
	next_button.set_disabled(Global.selected_players_ids.size() != 3)
	assert(Global.selected_players_ids.size() <= 3, 'Too many selected players ids')
