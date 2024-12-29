extends Util

@onready var menu: Menu = $/root/Menu
@onready var camera_3d: Camera3D = $Camera3D
@onready var game_state_manager: GameStateManager = $GameStateManager

var key_pressed: bool = false


func _ready() -> void:
	Global.engine_mode = EngineMode.GAME
	Global.editor = false
	
	adjust_camera_position()
	
	for default_to_free in get_children().filter(func(child): return child.is_in_group('ALWAYS_FREE')):
		default_to_free.queue_free()
	
	game_state_manager.progress()


func _process(delta: float) -> void:
	if not Input.is_anything_pressed():
		key_pressed = false


func _input(event: InputEvent) -> void:
	if Global.engine_mode != EngineMode.GAME:
		return
	
	if key_pressed:
		return
	
	if game_state_manager.map:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
			if is_close(camera_3d.rotation_degrees.x, -50):
				Global.camera_position = CameraPosition.MIDDLE
				adjust_camera_position()
			elif is_close(camera_3d.rotation_degrees.x, -40):
				Global.camera_position = CameraPosition.LOW
				adjust_camera_position()
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
			if is_close(camera_3d.rotation_degrees.x, -40):
				Global.camera_position = CameraPosition.HIGH
				adjust_camera_position()
			elif is_close(camera_3d.rotation_degrees.x, -30):
				Global.camera_position = CameraPosition.MIDDLE
				adjust_camera_position()
	
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
				tile.toggle_text(false)
				tile.reset_tile_models()
			
			game_state_manager.action_first_texture_button.set_pressed_no_signal(false)
			
			game_state_manager.recalculate_enemies_planned_actions()


func show_back() -> void:
	Global.engine_mode = EngineMode.GAME
	
	adjust_camera_position()
	toggle_visibility(true)


func adjust_camera_position():
	if Global.camera_position == CameraPosition.HIGH:
		camera_3d.rotation_degrees.x = -50
		camera_3d.position.y = 19.2
	elif Global.camera_position == CameraPosition.MIDDLE:
		camera_3d.rotation_degrees.x = -40
		camera_3d.position.y = 13.2
	elif Global.camera_position == CameraPosition.LOW:
		camera_3d.rotation_degrees.x = -30
		camera_3d.position.y = 9


func _on_settings_texture_button_pressed() -> void:
	toggle_visibility(false)
	
	menu.show_in_game_menu(self)
