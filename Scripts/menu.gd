extends Util

class_name Menu

@export var main_scene: PackedScene
@export var editor_scene: PackedScene
@export var cutscenes_scene: PackedScene

@onready var main_menu_button 				= $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/MainMenuButton
@onready var version_label 					= $CanvasLayer/PanelRightContainer/RightMarginContainer/RightBottomContainer/VersionLabel
@onready var main_menu_container			= $CanvasLayer/PanelCenterContainer/MainMenuContainer
@onready var editor_texture_button			= $CanvasLayer/PanelCenterContainer/MainMenuContainer/EditorTextureButton
@onready var tutorial_check_button			= $CanvasLayer/PanelCenterContainer/MainMenuContainer/TutorialCheckButton
@onready var continue_texture_button		= $CanvasLayer/PanelCenterContainer/MainMenuContainer/ContinueTextureButton
@onready var in_game_menu_container			= $CanvasLayer/PanelCenterContainer/InGameMenuContainer
@onready var options_container				= $CanvasLayer/PanelCenterContainer/OptionsContainer
@onready var language_option_button			= $CanvasLayer/PanelCenterContainer/OptionsContainer/LanguageHBoxContainer/LanguageOptionButton
@onready var camera_position_option_button	= $CanvasLayer/PanelCenterContainer/OptionsContainer/CameraPositionHBoxContainer/CameraPositionOptionButton
@onready var aa_check_box					= $CanvasLayer/PanelCenterContainer/OptionsContainer/AAHBoxContainer/AACheckBox
@onready var game_speed_h_slider			= $CanvasLayer/PanelCenterContainer/OptionsContainer/GameSpeedHBoxContainer/GameSpeedHSlider
@onready var volume_h_slider				= $CanvasLayer/PanelCenterContainer/OptionsContainer/VolumeHBoxContainer/VolumeHSlider
@onready var players_container				= $CanvasLayer/PanelCenterContainer/PlayersContainer
@onready var players_grid_container 		= $CanvasLayer/PanelCenterContainer/PlayersContainer/PlayersGridContainer
@onready var players_next_texture_button	= $CanvasLayer/PanelCenterContainer/PlayersContainer/PlayersNextTextureButton
@onready var save_slots_container			= $CanvasLayer/PanelCenterContainer/SaveSlotsContainer
@onready var save_slots_grid_container		= $CanvasLayer/PanelCenterContainer/SaveSlotsContainer/SaveSlotsGridContainer
@onready var panel_full_screen_container	= $CanvasLayer/PanelFullScreenContainer
@onready var ss_confirmation_color_rect		= $CanvasLayer/PanelFullScreenContainer/FullScreenCenterContainer/SSConfirmationColorRect
@onready var ss_confirmation_label			= $CanvasLayer/PanelFullScreenContainer/FullScreenCenterContainer/SSConfirmationColorRect/SSConfirmationPopup/SSConfirmationVBoxContainer/SSConfirmationLabel

# FIXME change when steam page is up
const STEAM_APP_ID = 480; # Spacewar (deprecated)

var init_manager_script: InitManager = preload('res://Scripts/init_manager.gd').new()

var last_screen: Util
var selected_save_object_id: int = -1


func _ready() -> void:
	Global.engine_mode = EngineMode.MENU
	
	TranslationServer.set_locale('en')
	version_label.text = 'version: ' + ProjectSettings.get_setting('application/config/version') + '-' + Time.get_date_string_from_system().replace('-', '')
	#main_menu_button.hide()
	
	tutorial_check_button.set_pressed(Global.tutorial)
	_on_tutorial_check_button_toggled(Global.tutorial)
	
	# is save slot selected
	continue_texture_button.set_visible(Global.save.id > 0)
	
	language_option_button.select(Global.settings.language)
	_on_language_option_button_item_selected(Global.settings.language)
	
	camera_position_option_button.select(Global.settings.camera_position)
	_on_camera_position_option_button_item_selected(Global.settings.camera_position)
	
	aa_check_box.set_pressed(Global.settings.antialiasing)
	_on_aa_check_box_toggled(Global.settings.antialiasing)
	
	_on_game_speed_h_slider_drag_ended(true)
	_on_volume_h_slider_drag_ended(true)
	
	on_button_disabled(players_next_texture_button, true)
	
	main_menu_container.show()
	if Global.build_mode == BuildMode.DEBUG:
		editor_texture_button.show()
	else:
		editor_texture_button.hide()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.hide()
	save_slots_container.hide()
	panel_full_screen_container.hide()
	ss_confirmation_color_rect.hide()
	
	init_steam()
	init_ui()


func _input(event: InputEvent) -> void:
	if Global.engine_mode != EngineMode.MENU:
		return


func init_steam() -> void:
	Steam.steamInitEx()
	if Steam.isSteamRunning():
		print('Steam is running for username: ' + Steam.getPersonaName())
	else:
		print('Steam is not running')


func init_ui() -> void:
	# player inventory
	for child in players_grid_container.get_children():
		child.hide()
	
	var index = 0
	var playable_players = init_manager_script.init_playable_players()
	assert(playable_players.size() >= 3, 'Wrong number of playable players')
	for playable_player in playable_players as Array[Player]:
		assert(playable_player.id != PlayerType.NONE, 'Wrong playable player id')
		var player_inventory = players_grid_container.get_child(index) as PlayerInventory
		player_inventory.init(playable_player)
		player_inventory.connect('player_inventory_mouse_entered', _on_player_inventory_mouse_entered)
		player_inventory.connect('player_inventory_mouse_exited', _on_player_inventory_mouse_exited)
		player_inventory.connect('player_inventory_toggled', _on_player_inventory_toggled)
		#player_inventory.texture_rect.scale = Vector2(0.75, 0.75)
		player_inventory.show()
		index += 1
	assert(players_grid_container.get_child_count() >= index, 'Wrong player inventory size')
	
	# save slots
	for child in save_slots_grid_container.get_children():
		child.hide()
	
	# TODO load
	for i in range(3):
		var save_slot = save_slots_grid_container.get_child(i) as SaveSlot
		var save_object = SaveObject.new()
		save_object.init()
		save_slot.init(save_object)
		save_slot.connect('slot_clicked', _on_save_slot_clicked)
		save_slot.show()


func show_in_game_menu(new_last_screen: Util) -> void:
	Global.engine_mode = EngineMode.MENU
	
	last_screen = new_last_screen
	
	#main_menu_button.hide()
	main_menu_container.hide()
	in_game_menu_container.show()
	options_container.hide()
	players_container.hide()
	save_slots_container.hide()
	panel_full_screen_container.hide()
	ss_confirmation_color_rect.hide()
	
	# this can be changed from inside the game
	camera_position_option_button.select(Global.settings.camera_position)
	_on_camera_position_option_button_item_selected(Global.settings.camera_position)
	
	toggle_visibility(true)


func show_main() -> void:
	toggle_visibility(false)
	
	add_sibling(main_scene.instantiate())


func show_save_slot_selection() -> void:
	# this is now done by selecting save slot
	#Global.save.selected_player_ids = []
	#Global.save.bought_item_ids = {}
	#Global.save.played_map_ids = []
	
	#main_menu_button.hide()
	main_menu_container.hide()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.hide()
	save_slots_container.show()
	panel_full_screen_container.hide()
	ss_confirmation_color_rect.hide()


func show_cutscenes() -> void:
	toggle_visibility(false)
	
	var cutscenes = cutscenes_scene.instantiate() as Cutscenes
	add_sibling(cutscenes)
	cutscenes.init(1)


func show_players_selection() -> void:
	for player_inventory in players_grid_container.get_children():
		var player_texture_button = player_inventory.avatar_texture_button
		player_texture_button.set_pressed_no_signal(false)
		#player_texture_button.modulate.a = 0.5
	
	#main_menu_button.hide()
	main_menu_container.hide()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.show()
	save_slots_container.hide()
	panel_full_screen_container.hide()
	ss_confirmation_color_rect.hide()


func _on_editor_texture_button_pressed() -> void:
	toggle_visibility(false)
	
	add_sibling(editor_scene.instantiate())


func _on_continue_texture_button_pressed() -> void:
	assert(Global.save.id > 0, 'Save slot was NOT selected')
	show_main()


func _on_start_texture_button_pressed() -> void:
	if Global.tutorial:
		Global.save.selected_player_ids.push_back(Util.PlayerType.PLAYER_TUTORIAL)
		show_main()
	else:
		show_save_slot_selection()


func _on_tutorial_check_button_toggled(toggled_on: bool) -> void:
	Global.tutorial = toggled_on


func _on_options_texture_button_pressed() -> void:
	#main_menu_button.hide()
	main_menu_container.hide()
	in_game_menu_container.hide()
	options_container.show()
	players_container.hide()
	save_slots_container.hide()
	panel_full_screen_container.hide()
	ss_confirmation_color_rect.hide()


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
	
	#main_menu_button.hide()
	main_menu_container.show()
	in_game_menu_container.hide()
	options_container.hide()
	players_container.hide()
	save_slots_container.hide()
	panel_full_screen_container.hide()
	ss_confirmation_color_rect.hide()
	
	continue_texture_button.set_visible(Global.save.id > 0)
	
	on_button_disabled(players_next_texture_button, true)
	
	toggle_visibility(true)
	
	for child_to_queue in get_tree().root.get_children().filter(func(child): return is_instance_valid(child) and not child.is_queued_for_deletion() and not child.is_in_group('NEVER_FREE')):
		child_to_queue.queue_free()


func _on_back_texture_button_pressed() -> void:
	#main_menu_button.hide()
	
	if get_node_or_null('/root/Main'):
		# in game
		main_menu_container.hide()
		in_game_menu_container.show()
	else:
		main_menu_container.show()
		in_game_menu_container.hide()
	
	options_container.hide()
	players_container.hide()
	save_slots_container.hide()
	panel_full_screen_container.hide()
	ss_confirmation_color_rect.hide()


func _on_difficulty_option_button_item_selected(index: int) -> void:
	Global.settings.difficulty = index


func _on_language_option_button_item_selected(index: int) -> void:
	Global.settings.language = index
	
	TranslationServer.set_locale(Language.keys()[Global.settings.language].to_lower())


func _on_camera_position_option_button_item_selected(index):
	Global.settings.camera_position = index


func _on_aa_check_box_toggled(toggled_on: bool) -> void:
	Global.settings.antialiasing = toggled_on
	
	if Global.settings.antialiasing:
		RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_8X)
	else:
		RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_DISABLED)


func _on_end_turn_confirmation_check_box_toggled(toggled_on: bool) -> void:
	Global.settings.end_turn_confirmation = toggled_on


func _on_game_speed_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.settings.game_speed = game_speed_h_slider.value


func _on_volume_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		# TODO implement
		Global.settings.volume = volume_h_slider.value


func _on_players_next_texture_button_pressed() -> void:
	show_main()


func _on_player_inventory_mouse_entered(id: PlayerType) -> void:
	pass


func _on_player_inventory_mouse_exited(id: PlayerType) -> void:
	pass


func _on_player_inventory_toggled(toggled_on: bool, id: PlayerType) -> void:
	if toggled_on:
		Global.save.selected_player_ids.push_back(id)
	else:
		Global.save.selected_player_ids.erase(id)
	
	on_button_disabled(players_next_texture_button, Global.save.selected_player_ids.size() != 3)
	assert(Global.save.selected_player_ids.size() <= 3, 'Too many selected player ids')


func _on_save_slot_clicked(save_object_id: int) -> void:
	selected_save_object_id = save_object_id
	
	for save_slot in save_slots_grid_container.get_children():
		if save_slot.save_object.id == selected_save_object_id:
			save_slot.modulate.a = 1.0
		else:
			save_slot.modulate.a = 0.5
	
	if Global.save.id == selected_save_object_id:
		ss_confirmation_label.text = 'SLOT ' + str(selected_save_object_id) + ' IS ALREADY SELECTED\n\nCONTINUE?'
	else:
		ss_confirmation_label.text = 'SLOT ' + str(selected_save_object_id) + ' WILL BE USED TO AUTOMATICALLY SAVE GAME\n\nCONTINUE?'
	
	panel_full_screen_container.show()
	ss_confirmation_color_rect.show()


func _on_ss_confirmation_no_button_pressed() -> void:
	var save_slot = save_slots_grid_container.get_children().filter(func(save_slot): return save_slot.save_object.id == selected_save_object_id).front() as SaveSlot
	save_slot.modulate.a = 0.5
	
	selected_save_object_id = -1
	
	panel_full_screen_container.hide()
	ss_confirmation_color_rect.hide()


func _on_ss_confirmation_yes_button_pressed() -> void:
	var save_slot = save_slots_grid_container.get_children().filter(func(save_slot): return save_slot.save_object.id == selected_save_object_id).front() as SaveSlot
	if Global.save.id == selected_save_object_id:
		# FIXME maybe compare each field separately
		assert(Global.save == save_slot.save_object, 'Already selected save slot is different than clicked one')
		_on_continue_texture_button_pressed()
	else:
		Global.save = save_slot.save_object
		
		players_container.show()
		save_slots_container.hide()
		panel_full_screen_container.hide()
		ss_confirmation_color_rect.hide()
