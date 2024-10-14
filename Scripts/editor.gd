extends Util

@export var map_scenes: Array[PackedScene] = []
@export var player_scenes: Array[PackedScene] = []
@export var enemy_scenes: Array[PackedScene] = []
@export var civilian_scenes: Array[PackedScene] = []
@export var assets_scene: PackedScene

@onready var menu = $/root/Menu
@onready var camera_3d = $Camera3D
@onready var level_generator = $LevelGenerator
@onready var game_state_manager = $GameStateManager
@onready var editor_label = $CanvasLayer/UI/EditorLabel
@onready var editor_container = $CanvasLayer/UI/EditorContainer
@onready var play_button = $CanvasLayer/UI/EditorContainer/PlayButton
@onready var reset_button = $CanvasLayer/UI/EditorContainer/ResetButton
@onready var delete_button = $CanvasLayer/UI/EditorContainer/DeleteButton
@onready var save_button = $CanvasLayer/UI/EditorContainer/SaveButton
@onready var load_menu_button = $CanvasLayer/UI/EditorContainer/LoadMenuButton
@onready var maps_menu_button = $CanvasLayer/UI/EditorContainer/MapsMenuButton
@onready var tiles_menu_button = $CanvasLayer/UI/EditorContainer/TilesContainer/TilesMenuButton
@onready var assets_menu_button = $CanvasLayer/UI/EditorContainer/AssetsMenuButton
@onready var players_menu_button = $CanvasLayer/UI/EditorContainer/PlayersMenuButton
@onready var enemies_menu_button = $CanvasLayer/UI/EditorContainer/EnemiesMenuButton
@onready var civilians_menu_button = $CanvasLayer/UI/EditorContainer/CiviliansMenuButton
@onready var selected_tile_menu_button = $CanvasLayer/UI/AlsoEditorContainer/SelectedTileMenuButton

const SAVED_LEVELS_FILE_PATH = 'res://Data/saved_levels.txt'

var assets: Array[Node3D] = []
var key_pressed: bool = false
var is_deleting: bool = false
var new_selected: bool = false

var level_data: Dictionary
var map: Node3D
var tile_to_placed: Dictionary
var selected_tile: Node3D
var selected_asset: Node3D
var selected: Node3D


func _ready():
	Global.engine_mode = Global.EngineMode.EDITOR
	
	assets.append_array(assets_scene.instantiate().get_children())
	
	load_menu_button.get_popup().connect('id_pressed', _on_load_id_pressed)
	load_menu_button.get_popup().set_hide_on_checkable_item_selection(false)
	maps_menu_button.get_popup().connect('id_pressed', _on_maps_id_pressed)
	tiles_menu_button.get_popup().connect('id_pressed', _on_tiles_id_pressed)
	assets_menu_button.get_popup().connect('id_pressed', _on_assets_id_pressed)
	players_menu_button.get_popup().connect('id_pressed', _on_players_id_pressed)
	enemies_menu_button.get_popup().connect('id_pressed', _on_enemies_id_pressed)
	civilians_menu_button.get_popup().connect('id_pressed', _on_civilians_id_pressed)
	selected_tile_menu_button.get_popup().connect('id_pressed', _on_selected_tile_id_pressed)
	selected_tile_menu_button.get_popup().set_hide_on_checkable_item_selection(false)
	
	init()


func _process(delta):
	if not Input.is_anything_pressed():
		key_pressed = false


func _input(event):
	if Global.engine_mode != Global.EngineMode.EDITOR:
		return
	
	if key_pressed:
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
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		reset()
	
	# LOG LEVEL DATA
	if Input.is_key_pressed(KEY_L):
		key_pressed = true
		print(level_data)
	
	# LOG TILES
	if Input.is_key_pressed(KEY_T):
		key_pressed = true
		print('tiles: ' + str(map.tiles.map(func(tile): return str(tile.coords) + ' ' + str(TileHealthType.keys()[tile.health_type]))))
	
	# LOG PLAYERS TILES
	if Input.is_key_pressed(KEY_P):
		key_pressed = true
		print('players tiles: ' + str(map.tiles.filter(func(tile): return tile.player).map(func(tile): return tile.coords)))
	
	# LOG ENEMIES TILES
	if Input.is_key_pressed(KEY_E):
		key_pressed = true
		print('enemies tiles: ' + str(map.tiles.filter(func(tile): return tile.enemy).map(func(tile): return tile.coords)))
	
	# LOG CIVILIANS TILES
	if Input.is_key_pressed(KEY_C):
		key_pressed = true
		print('civilians tiles: ' + str(map.tiles.filter(func(tile): return tile.civilian).map(func(tile): return tile.coords)))
	
	# LOG ASSETS TILES
	if Input.is_key_pressed(KEY_A):
		key_pressed = true
		print('assets tiles: ' + str(map.tiles.filter(func(tile): return tile.models.has('asset')).map(func(tile): return str(tile.coords) + ' -> ' + tile.models.asset.name)))


func init():
	reset()
	
	play_button.set_disabled(true)
	reset_button.set_disabled(true)
	delete_button.set_disabled(true)
	save_button.set_disabled(true)
	load_menu_button.set_disabled(false)
	maps_menu_button.set_disabled(false)
	tiles_menu_button.set_disabled(true)
	assets_menu_button.set_disabled(true)
	players_menu_button.set_disabled(true)
	enemies_menu_button.set_disabled(true)
	civilians_menu_button.set_disabled(true)
	level_data = {
		'map': {'scene': -1, 'level': -1, 'level_type': -1, 'tiles': '', 'tiles_assets': '', 'spawn_player_coords': [], 'spawn_enemy_coords': [], 'spawn_civilian_coords': [], 'max_turns': -1},
		'players': [],
		'enemies': [],
		'civilians': []
	}


func reset():
	delete_button.set_pressed_no_signal(false)
	selected_tile_menu_button.set_disabled(true)
	
	editor_label.text = 'nothing'
	selected_tile_menu_button.text = 'NO TILE SELECTED'
	is_deleting = false
	tile_to_placed = {}
	selected_tile = null
	selected_asset = null
	selected = null


func calculate_level_data(level = -1):
	if level >= 0:
		level_data.map.level = level
	level_data.map.tiles = ''
	level_data.map.tiles_assets = ''
	level_data.players = []
	level_data.enemies = []
	level_data.civilians = []
	#level_data.map.max_turns = 3
	
	for tile in map.tiles:
		level_data.map.tiles += map.convert_tile_type_enum_to_initial(tile.tile_type)
		
		if tile.models.has('asset'):
			level_data.map.tiles_assets += map.convert_asset_filename_to_initial(tile.models.asset.name)
		else:
			level_data.map.tiles_assets += map.convert_asset_filename_to_initial(null)
	
	var players_i = 0
	var enemies_i = 0
	var civilians_i = 0
	for child in get_children():
		# !!! CHANGE CHARACTER VALUES HERE !!!
		if child.is_in_group('PLAYERS'):
			if players_i == 0:
				level_data.players.push_back({'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': 0, 'action_type': -1, 'action_distance': 3})
			else:
				level_data.players.push_back({'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': 0, 'action_type': -1, 'action_distance': 3})
			players_i += 1
		
		if child.is_in_group('ENEMIES'):
			if enemies_i == 0:
				level_data.enemies.push_back({'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': 0, 'action_type': -1, 'action_distance': 3})
			else:
				level_data.enemies.push_back({'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': 0, 'action_type': -1, 'action_distance': 3})
			enemies_i += 1
		
		if child.is_in_group('CIVILIANS'):
			if civilians_i == 0:
				level_data.civilians.push_back({'scene': 0, 'health': 2, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': -1, 'action_type': -1, 'action_distance': 0})
			else:
				level_data.civilians.push_back({'scene': 0, 'health': 2, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': -1, 'action_type': -1, 'action_distance': 0})
			civilians_i += 1


func _on_main_menu_button_pressed():
	menu._on_main_menu_button_pressed()
	
	queue_free()


func _on_play_button_toggled(toggled_on):
	reset()
	
	reset_button.set_disabled(toggled_on)
	delete_button.set_disabled(toggled_on)
	save_button.set_disabled(toggled_on)
	load_menu_button.set_disabled(toggled_on)
	tiles_menu_button.set_disabled(toggled_on)
	assets_menu_button.set_disabled(toggled_on)
	players_menu_button.set_disabled(toggled_on)
	enemies_menu_button.set_disabled(toggled_on)
	civilians_menu_button.set_disabled(toggled_on)
	
	if toggled_on:
		editor_label.text = '* playing *'
		
		calculate_level_data()
		
		map.hide()
		
		for child in get_children():
			if child.is_in_group('PLAYERS'):
				child.hide()
			
			if child.is_in_group('ENEMIES'):
				child.hide()
			
			if child.is_in_group('CIVILIANS'):
				child.hide()
		
		game_state_manager.init(level_data)
	else:
		Global.engine_mode = Global.EngineMode.EDITOR
		
		# reset map for playing
		game_state_manager.next_level()
		
		map.show()
		
		for child in get_children():
			if child.is_in_group('PLAYERS'):
				child.show()
			
			if child.is_in_group('ENEMIES'):
				child.show()
			
			if child.is_in_group('CIVILIANS'):
				child.show()


func _on_reset_button_pressed():
	init()
	reset()
	
	if map:
		map.queue_free()
		map = null
	
	for child in get_children().filter(func(child): return child.is_in_group('PLAYERS') or child.is_in_group('ENEMIES') or child.is_in_group('CIVILIANS')):
		child.queue_free()
		child = null


func _on_delete_button_toggled(toggled_on):
	is_deleting = toggled_on
	if is_deleting:
		editor_label.text = 'deleting'
	else:
		editor_label.text = 'nothing'
	
	tile_to_placed = {}
	selected_tile = null
	selected_asset = null
	selected = null


func _on_save_button_pressed():
	var file = FileAccess.open(SAVED_LEVELS_FILE_PATH, FileAccess.READ_WRITE)
	var content = file.get_as_text()
	var level = content.count('->START') + 1
	
	calculate_level_data(level)
	
	content += '\n' + str(level) + '->START\n'
	# make it pretty
	#content += JSON.stringify(level_data, '\t')
	content += str(level_data)
	content += '\n' + str(level) + '->STOP\n'
	
	file.store_string(content)
	editor_label.text = 'map "' + str(level) + '" saved'


func _on_load_menu_button_about_to_popup():
	var file = FileAccess.open(SAVED_LEVELS_FILE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	var level = content.count('->START')
	if level != load_menu_button.get_popup().get_item_count():
		load_menu_button.get_popup().clear()
		
		for current_level in range(1, level + 1):
			# TODO how to show more details?
			load_menu_button.get_popup().add_item(str(current_level), current_level)


func _on_load_id_pressed(id):
	_on_reset_button_pressed()
	
	var file = FileAccess.open(SAVED_LEVELS_FILE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	var level_data_string = content.get_slice(str(id) + '->START', 1).get_slice(str(id) + '->STOP', 0).strip_escapes()
	level_data = level_generator.parse_data(level_data_string)
	
	_on_maps_id_pressed(level_data.map.scene)
	
	for tile in map.tiles:
		var index = map.get_side_dimension() * (tile.coords.x - 1) + (tile.coords.y - 1)
		var tile_type = map.convert_tile_type_initial_to_enum(level_data.map.tiles[index])
		var color = map.get_color_by_tile_type(tile_type)
		tile.tile_type = tile_type
		tile.model_material.albedo_color = color
		
		var asset_filename = map.convert_asset_initial_to_filename(level_data.map.tiles_assets[index])
		if asset_filename:
			var asset = assets.filter(func(asset): return asset.name == asset_filename).front().duplicate()
			asset.set_meta('tile', tile)
			asset.show()
			tile.add_child(asset)
			tile.models.asset = asset


func _on_maps_id_pressed(id):
	is_deleting = false
	
	play_button.set_disabled(false)
	reset_button.set_disabled(false)
	delete_button.set_disabled(false)
	save_button.set_disabled(false)
	delete_button.set_pressed_no_signal(false)
	maps_menu_button.set_disabled(true)
	tiles_menu_button.set_disabled(false)
	assets_menu_button.set_disabled(false)
	players_menu_button.set_disabled(false)
	enemies_menu_button.set_disabled(false)
	civilians_menu_button.set_disabled(false)
	
	map = map_scenes[id].instantiate()
	add_child(map)
	
	level_data.map.scene = id
	
	for tile in map.tiles:
		tile.area_3d.disconnect('mouse_entered', tile._on_area_3d_mouse_entered)
		tile.area_3d.disconnect('mouse_exited', tile._on_area_3d_mouse_exited)
		#tile.area_3d.disconnect('input_event', tile._on_area_3d_input_event)
		tile.connect('clicked_event', _on_editor_tile_clicked)
		tile.get_child(0).queue_free()
		var tile_asset = assets.filter(func(asset): return asset.name == 'ground_grass').front().duplicate()
		tile.tile_type = TileType.PLAIN
		tile.model_material.albedo_color = Color('e3cdaa')
		tile_asset.set_surface_override_material(1, tile.model_material)
		tile.models = {'tile': tile_asset}
		tile.add_child(tile.models.tile)
	
	editor_label.text = 'placed "' + map.name + '"'


func _on_color_picker_button_color_changed(color):
	delete_button.set_pressed_no_signal(false)
	is_deleting = false
	selected_tile = null
	selected_asset = null
	selected = null
	
	# mock, just for checking how the color looks on tile
	tile_to_placed = {'color': color, 'tile_type': TileType.PLAIN}


func _on_tiles_id_pressed(id):
	delete_button.set_pressed_no_signal(false)
	is_deleting = false
	selected_tile = null
	selected_asset = null
	selected = null
	
	tile_to_placed = {'color': map.get_color_by_tile_type(id), 'tile_type': id}
	
	editor_label.text = 'placing tile "' + TileType.keys()[tile_to_placed.tile_type] + '"'


func _on_assets_id_pressed(id):
	delete_button.set_pressed_no_signal(false)
	is_deleting = false
	tile_to_placed = {}
	selected_tile = null
	selected = null
	new_selected = true
	
	match id:
		0: selected_asset = assets.filter(func(asset): return asset.name == 'tree').front().duplicate()
		1: selected_asset = assets.filter(func(asset): return asset.name == 'mountain').front().duplicate()
		2: selected_asset = assets.filter(func(asset): return asset.name == 'volcano').front().duplicate()
		3: selected_asset = assets.filter(func(asset): return asset.name == 'sign').front().duplicate()
	
	editor_label.text = 'placing asset "' + selected_asset.name + '"'

# not used
func _on_players_id_pressed(id):
	delete_button.set_pressed_no_signal(false)
	is_deleting = false
	tile_to_placed = {}
	selected_tile = null
	selected_asset = null
	
	var player_instance = player_scenes[id].instantiate()
	selected = player_instance
	
	editor_label.text = 'placing "' + selected.name + '"'

# not used
func _on_enemies_id_pressed(id):
	delete_button.set_pressed_no_signal(false)
	is_deleting = false
	tile_to_placed = {}
	selected_tile = null
	selected_asset = null
	
	var enemy_instance = enemy_scenes[id].instantiate()
	selected = enemy_instance
	
	editor_label.text = 'placing "' + selected.name + '"'


# not used
func _on_civilians_id_pressed(id):
	delete_button.set_pressed_no_signal(false)
	is_deleting = false
	tile_to_placed = {}
	selected_tile = null
	selected_asset = null
	
	var civilian_instance = civilian_scenes[id].instantiate()
	selected = civilian_instance
	
	editor_label.text = 'placing "' + selected.name + '"'


func _on_selected_tile_id_pressed(id):
	selected_tile_menu_button.get_popup().set_item_checked(id, not selected_tile_menu_button.get_popup().is_item_checked(id))
	
	if selected_tile_menu_button.get_popup().is_item_checked(id):
		if id == 0:
			push_unique_to_array(level_data.map.spawn_player_coords, {'x': selected_tile.coords.x, 'y': selected_tile.coords.y})
		elif id == 1:
			push_unique_to_array(level_data.map.spawn_enemy_coords, {'x': selected_tile.coords.x, 'y': selected_tile.coords.y})
		elif id == 2:
			push_unique_to_array(level_data.map.spawn_civilian_coords, {'x': selected_tile.coords.x, 'y': selected_tile.coords.y})
		
		var spawn_indicator = assets.filter(func(asset): return asset.is_in_group('ASSETS_INDICATORS')).front().duplicate()
		spawn_indicator.show()
		selected_tile.add_child(spawn_indicator)
	else:
		if id == 0:
			level_data.map.spawn_player_coords.erase({'x': selected_tile.coords.x, 'y': selected_tile.coords.y})
		elif id == 1:
			level_data.map.spawn_enemy_coords.erase({'x': selected_tile.coords.x, 'y': selected_tile.coords.y})
		elif id == 2:
			level_data.map.spawn_civilian_coords.erase({'x': selected_tile.coords.x, 'y': selected_tile.coords.y})
		
		var spawn_indicator = selected_tile.get_children().filter(func(child): return child.is_in_group('ASSETS_INDICATORS')).front()
		if spawn_indicator:
			spawn_indicator.queue_free()
			spawn_indicator = null


func _on_editor_tile_clicked(tile):
	selected_tile = tile
	selected_tile_menu_button.text = 'SELECTED TILE ' + str(tile.coords)
	selected_tile_menu_button.set_disabled(false)
	selected_tile_menu_button.get_popup().set_item_checked(0, level_data.map.spawn_player_coords.any(func(spawn_player_coords): return spawn_player_coords.x == tile.coords.x and spawn_player_coords.y == tile.coords.y))
	selected_tile_menu_button.get_popup().set_item_checked(1, level_data.map.spawn_enemy_coords.any(func(spawn_enemy_coords): return spawn_enemy_coords.x == tile.coords.x and spawn_enemy_coords.y == tile.coords.y))
	selected_tile_menu_button.get_popup().set_item_checked(2, level_data.map.spawn_civilian_coords.any(func(spawn_civilian_coords): return spawn_civilian_coords.x == tile.coords.x and spawn_civilian_coords.y == tile.coords.y))
	
	var character = tile.get_character()
	if not tile_to_placed.is_empty():
		tile.tile_type = tile_to_placed.tile_type
		tile.model_material.albedo_color = tile_to_placed.color
		editor_label.text = 'changed tile ' + str(tile.coords) + ' type to "' + TileType.keys()[tile_to_placed.tile_type] + '"'
	elif selected or selected_asset:
		if character:
			selected = character
			tile_to_placed = {}
			selected_asset = null
			editor_label.text = 'selected "' + selected.name + '" from tile ' + str(tile.coords)
			new_selected = false
		elif tile.models.has('asset'):
			selected = null
			tile_to_placed = {}
			selected_asset = tile.models.asset
			editor_label.text = 'selected asset "' + selected_asset.name + '" from tile ' + str(tile.coords)
			new_selected = false
		else:
			if selected:
				if selected.tile:
					selected.tile.reset()
				else:
					selected.show()
					add_child(selected)
				
				selected.tile = tile
				tile.set_character(selected)
				selected.position = Vector3(tile.position.x, 0.0, tile.position.z)
				editor_label.text = 'placed "' + selected.name + '" on tile ' + str(tile.coords)
				new_selected = false
			elif selected_asset:
				if selected_asset.has_meta('tile'):
					var old_tile = map.tiles.filter(func(tile): return tile == selected_asset.get_meta('tile')).front()
					old_tile.models.asset.reparent(tile, false)
					old_tile.models.erase('asset')
				else:
					selected_asset.show()
					tile.add_child(selected_asset)
				
				selected_asset.set_meta('tile', tile)
				tile.models.asset = selected_asset
				editor_label.text = 'placed asset "' + selected_asset.name + '" on tile ' + str(tile.coords)
				if new_selected:
					selected_asset = assets.filter(func(asset): return selected_asset.name.begins_with(asset.name)).front().duplicate()
	else:
		if character:
			if is_deleting:
				editor_label.text = 'deleted "' + character.name + '" from tile ' + str(tile.coords)
				character.queue_free()
				tile.reset()
			else:
				selected = character
				editor_label.text = 'selected "' + selected.name + '" from tile ' + str(tile.coords)
		elif tile.models.has('asset'):
			if is_deleting:
				editor_label.text = 'deleted asset "' + tile.models.asset.name + '" from tile ' + str(tile.coords)
				tile.models.asset.queue_free()
				tile.models.erase('asset')
			else:
				selected_asset = tile.models.asset
				editor_label.text = 'selected asset "' + selected_asset.name + '" from tile ' + str(tile.coords)
		
		new_selected = false
