extends Util

@export var main_scene: PackedScene

@onready var player_buttons = $CanvasLayer/UI/PlayerButtons
@onready var menu_container = $CanvasLayer/UI/MenuContainer
@onready var tutorial_check_button = $CanvasLayer/UI/MenuContainer/TutorialCheckButton
@onready var players_container = $CanvasLayer/UI/PlayersContainer


func _ready():
	TranslationServer.set_locale('en')
	
	player_buttons.hide()
	menu_container.show()
	players_container.hide()
	
	tutorial_check_button.set_pressed(Global.tutorial)


func start():
	Global.test = false
	
	toggle_visibility(false)
	
	get_tree().root.add_child(main_scene.instantiate())


func _on_main_menu_button_pressed():
	player_buttons.hide()
	menu_container.show()
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


func _on_tutorial_check_button_toggled(toggled_on):
	Global.tutorial = toggled_on


func _on_player_button_pressed(player_type):
	print('you selected player type: ' + PlayerType.keys()[player_type])
	start()


func _on_language_check_button_toggled(toggled_on):
	if toggled_on:
		TranslationServer.set_locale('pl')
	else:
		TranslationServer.set_locale('en')
