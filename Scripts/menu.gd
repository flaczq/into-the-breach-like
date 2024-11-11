extends Util

class_name Menu

@export var main_scene: PackedScene
@export var editor_scene: PackedScene

@onready var player_buttons = $CanvasLayer/UI/PlayerButtons
@onready var main_menu_container = $CanvasLayer/UI/MainMenuContainer
@onready var editor_button = $CanvasLayer/UI/MainMenuContainer/EditorButton
@onready var tutorial_check_button = $CanvasLayer/UI/MainMenuContainer/TutorialCheckButton
@onready var in_game_menu_container = $CanvasLayer/UI/InGameMenuContainer
@onready var options_container = $CanvasLayer/UI/OptionsContainer
@onready var language_option_button = $CanvasLayer/UI/OptionsContainer/LanguageOptionButton
@onready var aa_check_box = $CanvasLayer/UI/OptionsContainer/AACheckBox
@onready var players_container = $CanvasLayer/UI/PlayersContainer
@onready var players_grid_container = $CanvasLayer/UI/PlayersContainer/PlayersGridContainer
@onready var player_1_texture_button = $CanvasLayer/UI/PlayersContainer/PlayersGridContainer/Player1Container/Player1TextureButton
@onready var player_2_texture_button = $CanvasLayer/UI/PlayersContainer/PlayersGridContainer/Player2Container/Player2TextureButton
@onready var player_3_texture_button = $CanvasLayer/UI/PlayersContainer/PlayersGridContainer/Player3Container/Player3TextureButton
@onready var next_button = $CanvasLayer/UI/PlayersContainer/NextButton
@onready var version_label = $CanvasLayer/UI/VersionLabel

var last_screen: Util


func _ready() -> void:
	Global.engine_mode = Global.EngineMode.MENU
	
	TranslationServer.set_locale('en')
	version_label.text = ProjectSettings.get_setting('application/config/version')
	
	tutorial_check_button.set_pressed(Global.tutorial)
	_on_tutorial_check_button_toggled(Global.tutorial)
	
	language_option_button.select(Global.language)
	_on_language_option_button_item_selected(Global.language)
	
	aa_check_box.set_pressed(Global.antialiasing)
	_on_aa_check_box_toggled(Global.antialiasing)
	
	next_button.set_disabled(true)
	
	player_buttons.hide()
	main_menu_container.show()
	if Global.build_mode == Global.BuildMode.DEBUG:
		editor_button.show()
	else:
		editor_button.hide()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.hide()


func _input(event: InputEvent):
	if Global.engine_mode != Global.EngineMode.MENU:
		return


func start():
	toggle_visibility(false)
	
	get_tree().root.add_child(main_scene.instantiate())


func show_in_game_menu(new_last_screen: Util):
	Global.engine_mode = Global.EngineMode.MENU
	
	last_screen = new_last_screen
	
	player_buttons.hide()
	main_menu_container.hide()
	in_game_menu_container.show()
	options_container.hide()
	players_container.hide()
	
	toggle_visibility(true)


func _on_editor_button_pressed():
	toggle_visibility(false)
	
	get_tree().root.add_child(editor_scene.instantiate())


func _on_start_button_pressed():
	if Global.tutorial:
		start()
	else:
		player_buttons.show()
		main_menu_container.hide()
		in_game_menu_container.hide()
		options_container.hide()
		players_container.show()


func _on_tutorial_check_button_toggled(toggled_on: bool):
	Global.tutorial = toggled_on


func _on_options_button_pressed():
	player_buttons.hide()
	main_menu_container.hide()
	in_game_menu_container.hide()
	options_container.show()
	players_container.hide()


func _on_exit_button_pressed():
	# TODO prompt for confirmation and save
	get_tree().quit()


func _on_resume_button_pressed():
	toggle_visibility(false)
	
	last_screen.show_back()
	last_screen = null


func _on_save_button_pressed():
	# TODO
	print('saved')


func _on_main_menu_button_pressed():
	Global.engine_mode = Global.EngineMode.MENU
	Global.players_scenes = []
	
	player_buttons.hide()
	main_menu_container.show()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.hide()
	next_button.set_disabled(true)
	
	# hardcoded
	player_1_texture_button.set_pressed_no_signal(false)
	player_1_texture_button.modulate.a = 0.5
	player_2_texture_button.set_pressed_no_signal(false)
	player_2_texture_button.modulate.a = 0.5
	player_3_texture_button.set_pressed_no_signal(false)
	player_3_texture_button.modulate.a = 0.5
	
	toggle_visibility(true)
	
	for child_to_queue in get_tree().root.get_children().filter(func(child): return is_instance_valid(child) and not child.is_queued_for_deletion() and not child.is_in_group('NEVER_FREED')):
		child_to_queue.queue_free()


func _on_back_button_pressed():
	player_buttons.hide()
	
	if get_node_or_null('/root/Main'):
		# in game
		main_menu_container.hide()
		in_game_menu_container.show()
	else:
		main_menu_container.show()
		in_game_menu_container.hide()
	
	options_container.hide()
	players_container.hide()


func _on_language_option_button_item_selected(index: int):
	Global.language = index
	
	TranslationServer.set_locale(Global.Language.keys()[Global.language].to_lower())


func _on_aa_check_box_toggled(toggled_on: bool):
	Global.antialiasing = toggled_on
	
	if Global.antialiasing:
		RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_8X)
	else:
		RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_DISABLED)


func _on_next_button_pressed():
	start()


func _on_player_texture_button_toggled(toggled_on: bool, id: int):
	var texture_player_button = players_grid_container.get_child(id - 1).get_child(0)
	
	# hardcoded
	if toggled_on:
		push_unique_to_array(Global.players_scenes, id)
		texture_player_button.modulate.a = 1.0
	else:
		Global.players_scenes.erase(id)
		texture_player_button.modulate.a = 0.5
	
	next_button.set_disabled(Global.players_scenes.size() != 3)
