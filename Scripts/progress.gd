extends Util

@onready var game_state_manager = $/root/Main/GameStateManager


func _on_main_menu_button_pressed():
	game_state_manager.get_parent()._on_main_menu_button_pressed()
	
	queue_free()


func _on_action_button_pressed(action):
	print('you chose action: ' + str(action+1))


func _on_map_type_button_pressed(map_type):
	print('you chose map type: ' + MapType.keys()[map_type])
	game_state_manager.get_parent().toggle_visibility(true)
	game_state_manager.next_level(map_type)
	
	queue_free()
