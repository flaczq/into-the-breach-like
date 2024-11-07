extends Util

@onready var menu = $/root/Menu
@onready var game_state_manager = $/root/Main/GameStateManager
@onready var actions_label = $CanvasLayer/UI/ProgressContainer/ActionsContainer/ActionsLabel

var selected_player_type: int
var selected_action_type: int


func _ready():
	Global.engine_mode = Global.EngineMode.MENU
	
	actions_label = 'Some sort of upgrade system\nCurrent loot: ' + str(Global.loot_count)


func show_back():
	Global.engine_mode = Global.EngineMode.MENU
	
	toggle_visibility(true)


func _on_menu_button_pressed():
	toggle_visibility(false)
	
	menu.show_in_game_menu(self)


func _on_action_button_pressed(action_type):
	print('you selected action type: ' + ActionType.keys()[action_type])
	selected_action_type = action_type


func _on_level_type_button_pressed(level_type):
	print('you selected level type: ' + LevelType.keys()[level_type])
	game_state_manager.get_parent().toggle_visibility(true)
	game_state_manager.init_by_level_type(level_type)
	
	queue_free()
