extends Util

@onready var game_state_manager = $/root/Main/GameStateManager

var selected_player_type: int
var selected_action_type: int


func _on_main_menu_button_pressed():
	game_state_manager.get_parent()._on_main_menu_button_pressed()
	
	queue_free()


func _on_action_button_pressed(action_type):
	print('you selected action type: ' + ActionType.keys()[action_type])
	selected_action_type = action_type


func _on_level_type_button_pressed(level_type):
	print('you selected level type: ' + LevelType.keys()[level_type])
	game_state_manager.get_parent().toggle_visibility(true)
	game_state_manager.next_level()
	game_state_manager.init(level_type)
	
	queue_free()
