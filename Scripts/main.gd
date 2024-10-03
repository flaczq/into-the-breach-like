extends Util

@onready var game_state_manager = $GameStateManager
@onready var camera_3d = $Camera3D
@onready var menu = $/root/Menu

const RANDOM_LEVELS_FILE_PATH = 'res://Data/random_levels.txt'

var key_pressed: bool = false


func _ready():
	var default_maps = get_children().filter(func(child): return child.is_in_group('MAPS'))
	if default_maps:
		for default_map in default_maps:
			default_map.queue_free()
	
	game_state_manager.progress()


func _process(delta):
	if not Input.is_anything_pressed():
		key_pressed = false


func _input(event):
	# only during level
	if key_pressed or not game_state_manager.is_visible():
		return
	
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
			
			if player.is_alive:
				player.reset_phase()
				player.reset_tiles()
	
		for tile in game_state_manager.map.tiles:
			#tile.is_clicked = false
			tile.ghost = null
			
			tile.reset_tile_models()
		
		game_state_manager.shoot_button.set_pressed_no_signal(false)
		game_state_manager.action_button.set_pressed_no_signal(false)
		
		game_state_manager.recalculate_enemies_planned_actions()
	
	# !DEBUG!
	# SAVE RANDOM MAP
	if Input.is_key_pressed(KEY_S):
		key_pressed = true
		var file = FileAccess.open(RANDOM_LEVELS_FILE_PATH, FileAccess.READ_WRITE)
		var content = file.get_as_text()
		content += '\nX->START\n'
		
		var map_dimension = sqrt(game_state_manager.map.tiles.size())
		for tile in game_state_manager.map.tiles:
			var index = map_dimension * (tile.coords.x - 1) + (tile.coords.y - 1)
			if index > 0 and int(index) % int(game_state_manager.map.get_side_dimension()) == 0:
				content += '\n'
			
			content += game_state_manager.map.convert_tile_type_enum_to_initial(tile.tile_type)
		
		content += '\nX->STOP\n'
		file.store_string(content)
		print('MAP SAVED')
	
	# LOG TILES
	if Input.is_key_pressed(KEY_T):
		print('tiles: ' + str(game_state_manager.map.tiles.map(func(tile): return str(tile.coords) + ' ' + str(TileHealthType.keys()[tile.health_type]))))
	
	# LOG DESTROYED TILES
	#if Input.is_key_pressed(KEY_D):
		#print('destroyed tiles: ' + str(game_state_manager.map.tiles.filter(func(tile): return tile.health_type == TileHealthType.DESTROYED).map(func(tile): return tile.coords)))
	
	# LOG PLAYERS TILES
	if Input.is_key_pressed(KEY_P):
		print('players tiles: ' + str(game_state_manager.map.tiles.filter(func(tile): return tile.player).map(func(tile): return tile.coords)))
	
	# LOG ENEMIES TILES
	if Input.is_key_pressed(KEY_E):
		print('enemies tiles: ' + str(game_state_manager.map.tiles.filter(func(tile): return tile.enemy).map(func(tile): return tile.coords)))
	
	# LOG CIVILIANS TILES
	if Input.is_key_pressed(KEY_C):
		print('civilians tiles: ' + str(game_state_manager.map.tiles.filter(func(tile): return tile.civilian).map(func(tile): return tile.coords)))
	
	# LOG PLANNED ENEMY ACTION TILES
	if Input.is_key_pressed(KEY_A):
		print('planned enemy action tiles: ' + str(game_state_manager.map.tiles.filter(func(tile): return tile.is_planned_enemy_action).map(func(tile): return tile.coords)))


func _on_main_menu_button_pressed():
	menu.toggle_visibility(true)
	
	queue_free()
