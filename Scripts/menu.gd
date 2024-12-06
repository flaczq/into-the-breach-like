extends Util

class_name Menu

@export var main_scene: PackedScene
@export var editor_scene: PackedScene
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

var player_1_script: Player = preload('res://Scripts/player1.gd').new()
var player_2_script: Player = preload('res://Scripts/player2.gd').new()
var player_3_script: Player = preload('res://Scripts/player3.gd').new()

var last_screen: Util


func _ready() -> void:
	Global.engine_mode = Global.EngineMode.MENU
	
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
	if Global.build_mode == Global.BuildMode.DEBUG:
		editor_button.show()
	else:
		editor_button.hide()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.hide()
	
	init_available_players(player_1_script)
	init_available_players(player_2_script)
	init_available_players(player_3_script)
	
	init_ui()


func _input(event: InputEvent) -> void:
	if Global.engine_mode != Global.EngineMode.MENU:
		return


func start() -> void:
	toggle_visibility(false)
	
	add_sibling(main_scene.instantiate())


func show_in_game_menu(new_last_screen: Util) -> void:
	Global.engine_mode = Global.EngineMode.MENU
	
	last_screen = new_last_screen
	
	right_container.hide()
	main_menu_container.hide()
	in_game_menu_container.show()
	options_container.hide()
	players_container.hide()
	
	camera_position_option_button.select(Global.camera_position)
	_on_camera_position_option_button_item_selected(Global.camera_position)
	
	toggle_visibility(true)


func init_ui() -> void:
	for default_player_container in players_grid_container.get_children().filter(func(child): return child.is_in_group('ALWAYS_FREE')):
		default_player_container.queue_free()
	
	assert(Global.available_players.size() >= 3, 'Too few available players')
	for available_player in Global.available_players as Array[PlayerObject]:
		var player_container = player_container_scene.instantiate() as PlayerContainer
		player_container.init(available_player.id, available_player.max_health, available_player.move_distance, available_player.damage, available_player.action_type, _on_player_texture_button_toggled)
		
		players_grid_container.add_child(player_container)


func init_available_players(player: Player) -> void:
	var player_object: PlayerObject = PlayerObject.new()
	var player_data = player.get_data()
	player_object.init_from_player_data(player_data)
	Global.available_players.push_back(player_object)


func _on_editor_button_pressed() -> void:
	toggle_visibility(false)
	
	add_sibling(editor_scene.instantiate())


func _on_start_button_pressed() -> void:
	if Global.tutorial:
		start()
	else:
		right_container.show()
		main_menu_container.hide()
		in_game_menu_container.hide()
		options_container.hide()
		players_container.show()


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
	Global.engine_mode = Global.EngineMode.MENU
	Global.selected_players = []
	
	right_container.hide()
	main_menu_container.show()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.hide()
	next_button.set_disabled(true)
	
	for player_container in players_grid_container.get_children():
		# FIXME disable state
		var player_texture_button = player_container.find_child('PlayerTextureButton')
		player_texture_button.set_pressed_no_signal(false)
		player_texture_button.modulate.a = 0.5
	
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
	
	TranslationServer.set_locale(Global.Language.keys()[Global.language].to_lower())


func _on_camera_position_option_button_item_selected(index):
	Global.camera_position = index


func _on_aa_check_box_toggled(toggled_on: bool) -> void:
	Global.antialiasing = toggled_on
	
	if Global.antialiasing:
		RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_8X)
	else:
		RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_DISABLED)


func _on_next_button_pressed() -> void:
	start()


func _on_player_texture_button_toggled(toggled_on: bool, index: int) -> void:
	assert(index >= 0, 'Wrong index')
	var player_container = players_grid_container.get_child(index)
	var player_texture_button = player_container.find_child('PlayerTextureButton')
	player_texture_button.modulate.a = (1.0) if (toggled_on) else (0.5)
	var selected_player = Global.available_players.filter(func(available_player): return available_player.id == index + 1).front()
	
	if toggled_on:
		Global.selected_players.push_back(selected_player)
	else:
		Global.selected_players.erase(selected_player)
	
	next_button.set_disabled(Global.selected_players.size() != 3)
	assert(Global.selected_players.size() <= 3, 'Too many selected players')
