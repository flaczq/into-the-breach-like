extends Util

@export var map_scenes: Array[PackedScene] = []
@export var player_scenes: Array[PackedScene] = []
@export var enemy_scenes: Array[PackedScene] = []
@export var civilian_scenes: Array[PackedScene] = []
@export var assets_scene: PackedScene

@onready var menu = $/root/Menu
@onready var camera_3d = $Camera3D
@onready var game_state_manager = $GameStateManager
@onready var editor_label = $CanvasLayer/UI/EditorLabel
@onready var editor_container = $CanvasLayer/UI/EditorContainer
@onready var play_button = $CanvasLayer/UI/EditorContainer/PlayButton
@onready var delete_button = $CanvasLayer/UI/EditorContainer/DeleteButton
@onready var save_button = $CanvasLayer/UI/EditorContainer/SaveButton
@onready var load_menu_button = $CanvasLayer/UI/EditorContainer/LoadMenuButton
@onready var maps_menu_button = $CanvasLayer/UI/EditorContainer/MapsMenuButton
@onready var tiles_menu_button = $CanvasLayer/UI/EditorContainer/TilesMenuButton
@onready var assets_menu_button = $CanvasLayer/UI/EditorContainer/AssetsMenuButton
#@onready var players_menu_button = $CanvasLayer/UI/EditorContainer/PlayersMenuButton
#@onready var enemies_menu_button = $CanvasLayer/UI/EditorContainer/EnemiesMenuButton
#@onready var civilians_menu_button = $CanvasLayer/UI/EditorContainer/CiviliansMenuButton
@onready var also_editor_container = $CanvasLayer/UI/AlsoEditorContainer
@onready var level_types_menu_button = $CanvasLayer/UI/AlsoEditorContainer/LevelTypesMenuButton
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
	assets.append_array(assets_scene.instantiate().get_children())
	
	load_menu_button.get_popup().connect('id_pressed', _on_load_item_clicked)
	maps_menu_button.get_popup().connect('id_pressed', _on_maps_item_clicked)
	tiles_menu_button.get_popup().connect('id_pressed', _on_tiles_item_clicked)
	assets_menu_button.get_popup().connect('id_pressed', _on_assets_item_clicked)
	level_types_menu_button.get_popup().connect('id_pressed', _on_level_types_item_clicked)
	#players_menu_button.get_popup().connect('id_pressed', _on_players_item_clicked)
	#enemies_menu_button.get_popup().connect('id_pressed', _on_enemies_item_clicked)
	#civilians_menu_button.get_popup().connect('id_pressed', _on_civilians_item_clicked)
	selected_tile_menu_button.get_popup().connect('id_pressed', _on_selected_tile_item_clicked)
	selected_tile_menu_button.get_popup().set_hide_on_checkable_item_selection(false)
	
	init()


func _process(delta):
	if not Input.is_anything_pressed():
		key_pressed = false


func _input(event):
	if key_pressed or not map:
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
	editor_label.text = 'NOTHING'
	selected_tile_menu_button.text = 'NO TILE SELECTED'
	play_button.set_disabled(true)
	delete_button.set_disabled(true)
	save_button.set_disabled(true)
	load_menu_button.set_disabled(true)
	maps_menu_button.set_disabled(false)
	tiles_menu_button.set_disabled(true)
	assets_menu_button.set_disabled(true)
	#players_menu_button.set_disabled(true)
	#enemies_menu_button.set_disabled(true)
	#civilians_menu_button.set_disabled(true)
	level_types_menu_button.set_disabled(true)
	selected_tile_menu_button.set_disabled(true)
	level_data = {
		'map': {'scene': -1, 'level': -1, 'level_type': -1, 'tiles': '', 'tiles_assets': '', 'spawn_player_coords': [], 'spawn_enemy_coords': [], 'spawn_civilian_coords': [], 'max_turns': -1},
		'players': [{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': 0, 'action_type': -1, 'action_distance': 3}],
		'enemies': [{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': 0, 'action_type': -1, 'action_distance': 3}],
		'civilians': [{'scene': 0, 'health': 2, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': -1, 'action_type': -1, 'action_distance': 0}]
	}


func reset():
	delete_button.set_pressed_no_signal(false)
	selected_tile_menu_button.set_disabled(true)
	
	editor_label.text = 'NOTHING'
	selected_tile_menu_button.text = 'NO TILE SELECTED'
	is_deleting = false
	tile_to_placed = {}
	selected_tile = null
	selected_asset = null
	selected = null



func _on_main_menu_button_pressed():
	menu._on_main_menu_button_pressed()
	menu.toggle_visibility(true)
	
	queue_free()


func _on_play_button_toggled(toggled_on):
	_on_save_button_pressed()
	
	reset()
	
	if toggled_on:
		#editor_label.hide()
		#editor_container.hide()
		#also_editor_container.hide()
		
		editor_label.text = 'PLAYING'
		
		map.hide()
		
		game_state_manager.init(level_data)
	else:
		editor_label.show()
		editor_container.show()
		also_editor_container.show()
		
		game_state_manager.next_level()
		
		map.show()


func _on_reset_button_pressed():
	init()
	reset()
	
	if map:
		map.queue_free()
		map = null
	
	for child in get_children().filter(func(child): return child.is_in_group('PLAYERS') or child.is_in_group('ENEMIES') or child.is_in_group('CIVILIANS')):
		child.queue_free()
		child = null


func _on_save_button_pressed():
	editor_label.text = 'SAVING'
	var file = FileAccess.open(SAVED_LEVELS_FILE_PATH, FileAccess.READ_WRITE)
	var content = file.get_as_text()
	var level = content.count('->START') + 1
	
	level_data.map.tiles = ''
	level_data.map.tiles_assets = ''
	
	for tile in map.tiles:
		var index = map.get_side_dimension() * (tile.coords.x - 1) + (tile.coords.y - 1)
		#if index > 0 and int(index) % int(map.get_side_dimension()) == 0:
			#content += '\n'
		
		level_data.map.tiles += map.convert_tile_type_enum_to_initial(tile.tile_type)
		
		if tile.models.has('asset'):
			level_data.map.tiles_assets += map.convert_asset_filename_to_initial(tile.models.asset.name)
		else:
			level_data.map.tiles_assets += map.convert_asset_filename_to_initial(null)
	
	level_data.map.level = level
	
	content += '\n' + str(level) + '->START\n'
	content += JSON.stringify(level_data, '\t')
	content += '\n' + str(level) + '->STOP\n'
	
	file.store_string(content)
	editor_label.text = 'MAP ' + str(level) + ' SAVED'


func _on_delete_button_toggled(toggled_on):
	is_deleting = toggled_on
	if is_deleting:
		editor_label.text = 'DELETING'
	else:
		editor_label.text = 'NOTHING'
	
	tile_to_placed = {}
	selected_tile = null
	selected_asset = null
	selected = null


func _on_load_item_clicked(id):
	# TODO
	print(id)


func _on_maps_item_clicked(id):
	is_deleting = false
	
	play_button.set_disabled(false)
	save_button.set_disabled(false)
	delete_button.set_disabled(false)
	maps_menu_button.set_disabled(true)
	tiles_menu_button.set_disabled(false)
	assets_menu_button.set_disabled(false)
	#players_menu_button.set_disabled(false)
	#enemies_menu_button.set_disabled(false)
	#civilians_menu_button.set_disabled(false)
	level_types_menu_button.set_disabled(false)
	
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
	
	editor_label.text = 'PLACED ' + map.name


func _on_tiles_item_clicked(id):
	is_deleting = false
	selected_tile = null
	selected_asset = null
	selected = null
	
	match id:
		0: tile_to_placed = {'color': Color('e3cdaa'), 'tile_type': TileType.PLAIN}
		1: tile_to_placed = {'color': Color('66ff3e'), 'tile_type': TileType.GRASS}
		2: tile_to_placed = {'color': Color('66ff3e'), 'tile_type': TileType.TREE}
		3: tile_to_placed = {'color': Color('4e3214'), 'tile_type': TileType.MOUNTAIN}
		4: tile_to_placed = {'color': Color('4e3214'), 'tile_type': TileType.VOLCANO}
		5: tile_to_placed = {'color': Color('3a8aff'), 'tile_type': TileType.WATER}
		6: tile_to_placed = {'color': Color('c54700'), 'tile_type': TileType.LAVA}
	
	editor_label.text = 'TILE TO PLACED ' + TileType.keys()[tile_to_placed.tile_type]


func _on_assets_item_clicked(id):
	is_deleting = false
	tile_to_placed = {}
	selected_tile = null
	selected = null
	new_selected = true
	
	match id:
		0: selected_asset = assets.filter(func(asset): return asset.name == 'tree').front().duplicate()
		1: selected_asset = assets.filter(func(asset): return asset.name == 'mountain').front().duplicate()
		2: selected_asset = assets.filter(func(asset): return asset.name == 'volcano').front().duplicate()
		3: selected_asset = assets.filter(func(asset): return asset.name == 'SIGN').front().duplicate()
	
	editor_label.text = 'ASSET TO PLACED ' + selected_asset.name


func _on_level_types_item_clicked(id):
	level_types_menu_button.get_popup().set_item_checked(0, false)
	level_types_menu_button.get_popup().set_item_checked(1, false)
	level_types_menu_button.get_popup().set_item_checked(2, false)
	level_types_menu_button.get_popup().set_item_checked(3, false)
	level_types_menu_button.get_popup().set_item_checked(id, not level_types_menu_button.get_popup().is_item_checked(id))
	level_data.map.level_type = id - 1


func _on_line_edit_text_submitted(new_text):
	level_data.map.max_turns = int(new_text)


#func _on_players_item_clicked(id):
	#is_deleting = false
	#tile_to_placed = {}
	#selected_tile = null
	#selected_asset = null
	#
	#var player_instance = player_scenes[id].instantiate()
	#selected = player_instance
	#
	#editor_label.text = 'TO PLACED ' + selected.name


#func _on_enemies_item_clicked(id):
	#is_deleting = false
	#tile_to_placed = {}
	#selected_tile = null
	#selected_asset = null
	#
	#var enemy_instance = enemy_scenes[id].instantiate()
	#selected = enemy_instance
	#
	#editor_label.text = 'TO PLACED ' + selected.name


#func _on_civilians_item_clicked(id):
	#is_deleting = false
	#tile_to_placed = {}
	#selected_tile = null
	#selected_asset = null
	#
	#var civilian_instance = civilian_scenes[id].instantiate()
	#selected = civilian_instance
	#
	#editor_label.text = 'TO PLACED ' + selected.name


func _on_selected_tile_item_clicked(id):
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
		editor_label.text = 'CHANGED TILE TYPE TO ' + TileType.keys()[tile_to_placed.tile_type] + ' ON TILE ' + str(tile.coords)
	elif selected or selected_asset:
		if character:
			selected = character
			tile_to_placed = {}
			selected_asset = null
			editor_label.text = 'SELECTED ' + selected.name
			new_selected = false
		elif tile.models.has('asset'):
			selected = null
			tile_to_placed = {}
			selected_asset = tile.models.asset
			editor_label.text = 'SELECTED ASSET ' + selected_asset.name
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
				editor_label.text = 'PLACED ' + selected.name + ' ON TILE ' + str(tile.coords)
				#if first_time:
					#selected = null
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
				editor_label.text = 'PLACED ASSET ' + selected_asset.name + ' ON TILE ' + str(tile.coords)
				if new_selected:
					selected_asset = assets.filter(func(asset): return asset.name == selected_asset.name).front().duplicate()
				else:
					selected_asset = null
	else:
		if character:
			if is_deleting:
				editor_label.text = 'DELETED ' + character.name + ' FROM TILE ' + str(tile.coords)
				character.queue_free()
				tile.reset()
			else:
				selected = character
				editor_label.text = 'SELECTED ' + selected.name
		elif tile.models.has('asset'):
			if is_deleting:
				editor_label.text = 'DELETED ASSET ' + tile.models.asset.name + ' FROM TILE ' + str(tile.coords)
				tile.models.asset.queue_free()
				tile.models.erase('asset')
			else:
				selected_asset = tile.models.asset
				editor_label.text = 'SELECTED ASSET ' + selected_asset.name
		
		new_selected = false
