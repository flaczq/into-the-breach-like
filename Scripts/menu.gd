extends Util

@export var main_scene: PackedScene

@onready var player_buttons = $CanvasLayer/UI/PlayerButtons
@onready var menu_container = $CanvasLayer/UI/MenuContainer
@onready var tutorial_check_button = $CanvasLayer/UI/MenuContainer/TutorialCheckButton
@onready var options_container = $CanvasLayer/UI/OptionsContainer
@onready var language_option_button = $CanvasLayer/UI/OptionsContainer/LanguageOptionButton
@onready var aa_check_box = $CanvasLayer/UI/OptionsContainer/AACheckBox
@onready var players_container = $CanvasLayer/UI/PlayersContainer
@onready var version_label = $CanvasLayer/UI/VersionLabel


func _ready():
	TranslationServer.set_locale('en')
	version_label.text = ProjectSettings.get_setting('application/config/version')
	
	tutorial_check_button.set_pressed(Global.tutorial)
	_on_tutorial_check_button_toggled(Global.tutorial)
	
	language_option_button.select(Global.language)
	_on_language_option_button_item_selected(Global.language)
	
	aa_check_box.set_pressed(Global.aa)
	_on_aa_check_box_toggled(Global.aa)
	
	_on_main_menu_button_pressed()


func start():
	Global.test = false
	
	toggle_visibility(false)
	
	get_tree().root.add_child(main_scene.instantiate())


func _on_main_menu_button_pressed():
	player_buttons.hide()
	menu_container.show()
	options_container.hide()
	players_container.hide()


# TODO delete on release !!!
func _on_test_button_pressed():
	Global.test = true
	
	toggle_visibility(false)
	
	get_tree().root.add_child(main_scene.instantiate())


func _on_start_button_pressed():
	if Global.tutorial:
		start()
	else:
		player_buttons.show()
		menu_container.hide()
		players_container.show()


func _on_options_button_pressed():
	player_buttons.show()
	menu_container.hide()
	options_container.show()


func _on_tutorial_check_button_toggled(toggled_on):
	Global.tutorial = toggled_on


func _on_player_button_pressed(player_type):
	print('you selected player type: ' + PlayerType.keys()[player_type])
	start()


func _on_language_option_button_item_selected(index):
	Global.language = index
	
	TranslationServer.set_locale(Global.Language.keys()[Global.language].to_lower())


func _on_aa_check_box_toggled(toggled_on):
	Global.aa = toggled_on
	
	if Global.aa:
		RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_8X)
	else:
		RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_DISABLED)
