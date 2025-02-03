extends Util

@export var assets_scene: PackedScene
@export var map_scenes: Array[PackedScene] = []
@export var player_scenes: Array[PackedScene] = []
@export var enemy_scenes: Array[PackedScene] = []
@export var civilian_scenes: Array[PackedScene] = []

@onready var menu: Menu = $/root/Menu
@onready var camera_3d: Camera3D = $Camera3D
@onready var game_state_manager: GameStateManager = $GameStateManager
@onready var editor_label = $CanvasLayer/EditorLabel
@onready var end_turn_texture_button = $CanvasLayer/PanelLeftContainer/LeftMarginContainer/LeftContainer/LeftTopContainer/EndTurnTextureButton
@onready var action_first_texture_button = $CanvasLayer/PanelLeftContainer/LeftMarginContainer/LeftContainer/LeftTopContainer/ActionFirstTextureButton
@onready var undo_texture_button = $CanvasLayer/PanelLeftContainer/LeftMarginContainer/LeftContainer/LeftTopContainer/UndoTextureButton
@onready var play_button = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/RightBottomContainer/PlayButton
@onready var reset_button = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/RightBottomContainer/ResetButton
@onready var delete_button = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/RightBottomContainer/DeleteButton
@onready var save_button = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/RightBottomContainer/SaveButton
@onready var load_menu_button = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/RightBottomContainer/LoadMenuButton
@onready var maps_menu_button = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/RightBottomContainer/MapsMenuButton
@onready var tiles_menu_button = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/RightBottomContainer/TilesContainer/TilesMenuButton
@onready var assets_menu_button = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/RightBottomContainer/AssetsMenuButton
@onready var players_menu_button = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/RightBottomContainer/PlayersMenuButton
@onready var enemies_menu_button = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/RightBottomContainer/EnemiesMenuButton
@onready var civilians_menu_button = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/RightBottomContainer/CiviliansMenuButton
@onready var selected_tile_menu_button = $CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/RightBottomContainer/SelectedTileMenuButton

const SAVED_LEVELS_FILE_PATH = 'res://Other/saved_levels.txt'

var level_manager_script: LevelManager = preload('res://Scripts/level_manager.gd').new()

var assets: Array[Node3D] = []
var key_pressed: bool = false
var is_deleting: bool = false
var new_selected: bool = false

var level_data: Dictionary
var map: Map
var tile_to_placed: Dictionary
var selected_tile: MapTile
var selected_asset: Asset
var selected: Node3D


func _ready() -> void:
	Global.engine_mode = EngineMode.EDITOR
	Global.editor = true
	
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


func _process(delta: float) -> void:
	if not Input.is_anything_pressed():
		key_pressed = false


func _input(event: InputEvent) -> void:
	if key_pressed:
		return
	
	if map:
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
	
		# LOG LEVEL DATA
		if Input.is_key_pressed(KEY_L):
			key_pressed = true
			print(level_data)
		
		# LOG TILES
		if Input.is_key_pressed(KEY_T):
			key_pressed = true
			print('tiles: ' + str(map.tiles.map(func(tile: MapTile): return str(tile.coords) + ' ' + str(TileHealthType.keys()[tile.health_type]))))
		
		# LOG PLAYERS TILES
		if Input.is_key_pressed(KEY_P):
			key_pressed = true
			print('players tiles: ' + str(map.tiles.filter(func(tile: MapTile): return tile.player).map(func(tile: MapTile): return tile.coords)))
		
		# LOG ENEMIES TILES
		if Input.is_key_pressed(KEY_E):
			key_pressed = true
			print('enemies tiles: ' + str(map.tiles.filter(func(tile: MapTile): return tile.enemy).map(func(tile: MapTile): return tile.coords)))
		
		# LOG CIVILIANS TILES
		if Input.is_key_pressed(KEY_C):
			key_pressed = true
			print('civilians tiles: ' + str(map.tiles.filter(func(tile: MapTile): return tile.civilian).map(func(tile: MapTile): return tile.coords)))
		
		# LOG ASSETS TILES
		if Input.is_key_pressed(KEY_A):
			key_pressed = true
			print('assets tiles: ' + str(map.tiles.filter(func(tile: MapTile): return tile.models.asset).map(func(tile: MapTile): return str(tile.coords) + ' -> ' + tile.models.asset.name)))
	
	if Global.engine_mode != EngineMode.EDITOR:
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		reset()


func init() -> void:
	reset()
	
	on_button_disabled(end_turn_texture_button, true)
	on_button_disabled(action_first_texture_button, true)
	on_button_disabled(undo_texture_button, true)
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
		'scene': -1, 'level': -1, 'level_type': -1, 'level_events': [], 'tiles': '', 'tiles_assets': '', 'spawn_player_coords': [], 'spawn_enemy_coords': [], 'spawn_civilian_coords': []
	}


func reset() -> void:
	delete_button.set_pressed_no_signal(false)
	selected_tile_menu_button.set_disabled(true)
	
	editor_label.text = 'nothing'
	selected_tile_menu_button.text = 'NO TILE SELECTED'
	is_deleting = false
	tile_to_placed = {}
	selected_tile = null
	selected_asset = null
	selected = null


func calculate_level_data() -> void:
	#########################
	# ┓ ┏┓┓┏┏┓┓   ┳┓┏┓┏┳┓┏┓ #
	# ┃ ┣ ┃┃┣ ┃   ┃┃┣┫ ┃ ┣┫ #
	# ┗┛┗┛┗┛┗┛┗┛  ┻┛┛┗ ┻ ┛┗ #
	#########################
	
	# FIXME all levels are 1 for now, later group them by levels and pick random
	level_data.level = 1
	level_data.level_type = 1
	level_data.level_events = [LevelEvent.ENEMIES_FROM_BELOW, LevelEvent.ENEMIES_FROM_BELOW]
	level_manager_script.add_events_details(level_data, enemy_scenes.size())
	level_manager_script.add_level_type_details(level_data)
	level_data.tiles = ''
	level_data.tiles_assets = ''
	level_data.player_scenes = []
	level_data.enemy_scenes = []
	level_data.civilian_scenes = []
	
	for tile in map.tiles:
		level_data.tiles += map.convert_tile_type_enum_to_initial(tile.tile_type)
		
		var asset = (tile.models.asset.name) if (tile.models.get('asset')) else ''
		level_data.tiles_assets += map.convert_asset_filename_to_initial(asset)
	
	if get_children().all(func(child): return not child.is_in_group('PLAYERS') and not child.is_in_group('ENEMIES') and not child.is_in_group('CIVILIANS')):
		# place 3 default players and enemies
		level_data.player_scenes = [1,2,3]
		level_data.enemy_scenes = [1,2,3]
	else:
		for child in get_children():
			if child.is_in_group('PLAYERS'):
				level_data.player_scenes.push_back(child.id)
			elif child.is_in_group('ENEMIES'):
				level_data.enemy_scenes.push_back(child.id)
			elif child.is_in_group('CIVILIANS'):
				level_data.civilian_scenes.push_back(child.id)


func _on_settings_texture_button_pressed() -> void:
	menu._on_main_menu_button_pressed()
	
	queue_free()


func _on_play_button_toggled(toggled_on: bool) -> void:
	reset()
	
	on_button_disabled(end_turn_texture_button, not toggled_on)
	on_button_disabled(action_first_texture_button, not toggled_on)
	on_button_disabled(undo_texture_button, not toggled_on)
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
		Global.engine_mode = EngineMode.EDITOR
		
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


func _on_reset_button_pressed() -> void:
	init()
	reset()
	
	if map:
		map.queue_free()
		map = null
	
	for child in get_children().filter(func(child): return child.is_in_group('PLAYERS') or child.is_in_group('ENEMIES') or child.is_in_group('CIVILIANS')):
		child.queue_free()
		child = null


func _on_delete_button_toggled(toggled_on: bool) -> void:
	is_deleting = toggled_on
	if is_deleting:
		editor_label.text = 'deleting'
	else:
		editor_label.text = 'nothing'
	
	tile_to_placed = {}
	selected_tile = null
	selected_asset = null
	selected = null


func _on_save_button_pressed() -> void:
	var file = FileAccess.open(SAVED_LEVELS_FILE_PATH, FileAccess.READ_WRITE)
	var content = file.get_as_text()
	var index = content.count('->START') + 1
	
	calculate_level_data()
	
	# level_manager will add characters and events
	#level_data.erase('level_events')
	level_data.erase('players')
	level_data.erase('player_scenes')
	level_data.erase('enemies')
	level_data.erase('enemy_scenes')
	level_data.erase('civilians')
	level_data.erase('civilian_scenes')
	level_data.erase('max_enemies')
	level_data.erase('enemies_from_below')
	level_data.erase('enemies_from_below_first_turn')
	level_data.erase('enemies_from_below_last_turn')
	level_data.erase('enemies_from_above')
	level_data.erase('enemies_from_above_first_turn')
	level_data.erase('enemies_from_above_last_turn')
	
	var prefix = '-' + str(level_data.level) + '-' + str(level_data.level_type) + '->'
	content += '\n' + str(index) + prefix + 'START\n'
	# make it pretty
	#content += JSON.stringify(level_data, '\t')
	content += str(level_data)
	content += '\n' + str(index) + prefix + 'STOP\n'
	
	file.store_string(content)
	editor_label.text = 'map "' + str(index) + '" saved'


func _on_load_menu_button_about_to_popup() -> void:
	var file = FileAccess.open(SAVED_LEVELS_FILE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	var index = content.count('->START')
	if index != load_menu_button.get_popup().get_item_count():
		load_menu_button.get_popup().clear()
		
		for i in range(1, index + 1):
			# TODO how to show more details?
			load_menu_button.get_popup().add_item(str(i), i)


func _on_load_id_pressed(id: int) -> void:
	_on_reset_button_pressed()
	
	var file = FileAccess.open(SAVED_LEVELS_FILE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	# FIXME hardcoded
	var level_data_string = content.get_slice(str(id) + '-1-1->START', 1).get_slice(str(id) + '-1-1->STOP', 0).strip_escapes()
	level_data = level_manager_script.parse_data(level_data_string)
	#level_manager_script.add_events_details(level_data, enemy_scenes.size())
	
	_on_maps_id_pressed(level_data.scene)
	
	for tile in map.tiles:
		var index = map.get_side_dimension() * (tile.coords.x - 1) + (tile.coords.y - 1)
		var tile_type = map.convert_tile_type_initial_to_enum(level_data.tiles[index])
		var color = map.get_color_by_tile_type(tile_type)
		tile.tile_type = tile_type
		tile.model_material.albedo_color = color
		
		var asset_filename = map.convert_asset_initial_to_filename(level_data.tiles_assets[index])
		if asset_filename:
			var asset = assets.filter(func(asset): return asset.name == asset_filename).front().duplicate()
			asset.set_meta('tile', tile)
			asset.show()
			tile.add_child(asset)
			tile.models.asset = asset
		
		var vector2i_tiles_coords = convert_spawn_coords_to_vector_coords(level_data.spawn_player_coords)
		vector2i_tiles_coords += convert_spawn_coords_to_vector_coords(level_data.spawn_enemy_coords)
		vector2i_tiles_coords += convert_spawn_coords_to_vector_coords(level_data.spawn_civilian_coords)
		if vector2i_tiles_coords.has(tile.coords):
			var spawn_indicator = assets.filter(func(asset): return asset.is_in_group('INDICATORS')).front().duplicate()
			spawn_indicator.show()
			tile.add_child(spawn_indicator)


func _on_maps_id_pressed(id: int) -> void:
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
	
	level_data.scene = id
	
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
		tile.models = {
			'tile': tile_asset,
			'asset': null
		}
		tile.add_child(tile.models.tile)
	
	editor_label.text = 'placed "' + map.name + '"'


func _on_color_picker_button_color_changed(color: Color) -> void:
	delete_button.set_pressed_no_signal(false)
	is_deleting = false
	selected_tile = null
	selected_asset = null
	selected = null
	
	# mock, just for checking how the color looks on tile
	tile_to_placed = {'color': color, 'tile_type': TileType.PLAIN}


func _on_tiles_id_pressed(id: int):
	delete_button.set_pressed_no_signal(false)
	is_deleting = false
	selected_tile = null
	selected_asset = null
	selected = null
	
	tile_to_placed = {'color': map.get_color_by_tile_type(id), 'tile_type': id}
	
	editor_label.text = 'placing tile "' + TileType.keys()[tile_to_placed.tile_type] + '"'


func _on_assets_id_pressed(id: int) -> void:
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
		4: selected_asset = assets.filter(func(asset): return asset.name == 'indicator-special-cross').front().duplicate()
		5: selected_asset = assets.filter(func(asset): return asset.name == 'house').front().duplicate()
	
	editor_label.text = 'placing asset "' + selected_asset.name + '"'

func _on_players_id_pressed(id: int) -> void:
	delete_button.set_pressed_no_signal(false)
	is_deleting = false
	tile_to_placed = {}
	selected_tile = null
	selected_asset = null
	
	var player_instance = player_scenes[id].instantiate()
	selected = player_instance
	
	editor_label.text = 'placing "' + selected.name + '"'

func _on_enemies_id_pressed(id: int) -> void:
	delete_button.set_pressed_no_signal(false)
	is_deleting = false
	tile_to_placed = {}
	selected_tile = null
	selected_asset = null
	
	var enemy_instance = enemy_scenes[id].instantiate()
	selected = enemy_instance
	
	editor_label.text = 'placing "' + selected.name + '"'

func _on_civilians_id_pressed(id: int) -> void:
	delete_button.set_pressed_no_signal(false)
	is_deleting = false
	tile_to_placed = {}
	selected_tile = null
	selected_asset = null
	
	var civilian_instance = civilian_scenes[id].instantiate()
	selected = civilian_instance
	
	editor_label.text = 'placing "' + selected.name + '"'


func _on_selected_tile_id_pressed(id: int) -> void:
	selected_tile_menu_button.get_popup().set_item_checked(id, not selected_tile_menu_button.get_popup().is_item_checked(id))
	
	if selected_tile_menu_button.get_popup().is_item_checked(id):
		if id == 0:
			push_unique_to_array(level_data.spawn_player_coords, {'x': selected_tile.coords.x, 'y': selected_tile.coords.y})
		elif id == 1:
			push_unique_to_array(level_data.spawn_enemy_coords, {'x': selected_tile.coords.x, 'y': selected_tile.coords.y})
		elif id == 2:
			push_unique_to_array(level_data.spawn_civilian_coords, {'x': selected_tile.coords.x, 'y': selected_tile.coords.y})
		
		var spawn_indicator = assets.filter(func(asset): return asset.is_in_group('INDICATORS')).front().duplicate()
		spawn_indicator.show()
		selected_tile.add_child(spawn_indicator)
	else:
		if id == 0:
			var tile_coords = level_data.spawn_player_coords.filter(func(tile_coords: Dictionary): return tile_coords.x == selected_tile.coords.x and tile_coords.y == selected_tile.coords.y).front()
			if tile_coords:
				level_data.spawn_player_coords.erase(tile_coords)
		elif id == 1:
			var tile_coords = level_data.spawn_enemy_coords.filter(func(tile_coords: Dictionary): return tile_coords.x == selected_tile.coords.x and tile_coords.y == selected_tile.coords.y).front()
			if tile_coords:
				level_data.spawn_enemy_coords.erase(tile_coords)
		elif id == 2:
			var tile_coords = level_data.spawn_civilian_coords.filter(func(tile_coords: Dictionary): return tile_coords.x == selected_tile.coords.x and tile_coords.y == selected_tile.coords.y).front()
			if tile_coords:
				level_data.spawn_civilian_coords.erase(tile_coords)
		
		var spawn_indicator = selected_tile.get_children().filter(func(child): return child.is_in_group('INDICATORS')).front()
		if spawn_indicator:
			spawn_indicator.queue_free()
			spawn_indicator = null


func _on_editor_tile_clicked(tile: MapTile) -> void:
	selected_tile = tile
	selected_tile_menu_button.text = 'SELECTED TILE ' + str(tile.coords)
	selected_tile_menu_button.set_disabled(false)
	selected_tile_menu_button.get_popup().set_item_checked(0, convert_spawn_coords_to_vector_coords(level_data.spawn_player_coords).has(tile.coords))
	selected_tile_menu_button.get_popup().set_item_checked(1, convert_spawn_coords_to_vector_coords(level_data.spawn_enemy_coords).has(tile.coords))
	selected_tile_menu_button.get_popup().set_item_checked(2, convert_spawn_coords_to_vector_coords(level_data.spawn_civilian_coords).has(tile.coords))
	
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
		elif tile.models.get('asset'):
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
					var old_tile = map.tiles.filter(func(tile: MapTile): return tile == selected_asset.get_meta('tile')).front()
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
		elif tile.models.get('asset'):
			if is_deleting:
				editor_label.text = 'deleted asset "' + tile.models.asset.name + '" from tile ' + str(tile.coords)
				tile.models.asset.queue_free()
				tile.models.erase('asset')
			else:
				selected_asset = tile.models.asset
				editor_label.text = 'selected asset "' + selected_asset.name + '" from tile ' + str(tile.coords)
		
		new_selected = false
