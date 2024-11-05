extends Util

@onready var menu = $/root/Menu
@onready var camera_3d = $Camera3D
@onready var game_state_manager = $GameStateManager

var key_pressed: bool = false


func _ready():
	Global.engine_mode = Global.EngineMode.GAME
	Global.editor = false
	
	var default_maps = get_children().filter(func(child): return child.is_in_group('MAPS'))
	if default_maps:
		for default_map in default_maps:
			default_map.queue_free()
	
	game_state_manager.progress()


func _process(delta):
	if not Input.is_anything_pressed():
		key_pressed = false


func _input(event):
	if Global.engine_mode != Global.EngineMode.GAME:
		return
	
	if key_pressed:
		return
	
	if game_state_manager.map:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
			if is_close(camera_3d.rotation_degrees.x, -50):
				camera_3d.rotation_degrees.x = -40
				camera_3d.position.y = 13.2
			elif is_close(camera_3d.rotation_degrees.x, -40):
				camera_3d.rotation_degrees.x = -30
				camera_3d.position.y = 9
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
			if is_close(camera_3d.rotation_degrees.x, -40):
				camera_3d.rotation_degrees.x = -50
				camera_3d.position.y = 19.2
			elif is_close(camera_3d.rotation_degrees.x, -30):
				camera_3d.rotation_degrees.x = -40
				camera_3d.position.y = 13.2
	
		# UNCLICK PLAYER
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			game_state_manager.reset_ui()
			
			for player in game_state_manager.players:
				#player.is_clicked = false
				player.is_ghost = false
				player.clear_arrows()
				player.clear_action_indicators()
				player.toggle_health_bar(false)
				
				if player.is_alive:
					player.reset_phase()
					player.reset_tiles()
			
			for enemy in game_state_manager.enemies:
				enemy.toggle_health_bar(false)
			
			for civilian in game_state_manager.civilians:
				civilian.toggle_health_bar(false)
			
			for tile in game_state_manager.map.tiles:
				#tile.is_clicked = false
				tile.ghost = null
				
				tile.reset_tile_models()
			
			game_state_manager.shoot_button.set_pressed_no_signal(false)
			game_state_manager.action_button.set_pressed_no_signal(false)
			
			game_state_manager.recalculate_enemies_planned_actions()


func show_back():
	Global.engine_mode = Global.EngineMode.GAME
	
	toggle_visibility(true)


func _on_settings_texture_rect_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_visibility(false)
		
		menu.show_in_game_menu(self)
