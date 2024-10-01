extends Util

@onready var game_state_manager = $/root/Main/GameStateManager


func _on_main_button_pressed():
	game_state_manager.get_parent().toggle_visibility(true)
	
	game_state_manager.next_level()
	
	queue_free()
