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
@onready var play_button = $CanvasLayer/UI/EditorContainer/PlayButton
@onready var save_button = $CanvasLayer/UI/EditorContainer/SaveButton
@onready var delete_button = $CanvasLayer/UI/EditorContainer/DeleteButton
@onready var maps_option_button = $CanvasLayer/UI/EditorContainer/MapsOptionButton
@onready var tiles_option_button = $CanvasLayer/UI/EditorContainer/TilesOptionButton
@onready var assets_option_button = $CanvasLayer/UI/EditorContainer/AssetsOptionButton
@onready var players_option_button = $CanvasLayer/UI/EditorContainer/PlayersOptionButton
@onready var enemies_option_button = $CanvasLayer/UI/EditorContainer/EnemiesOptionButton
@onready var civilians_option_button = $CanvasLayer/UI/EditorContainer/CiviliansOptionButton


const SAVED_LEVELS_FILE_PATH = 'res://Data/saved_levels.txt'

var key_pressed: bool = false
var assets: Array[Node3D] = []
var is_deleting: bool = false

var map: Node3D
var selected: Node3D
var selected_tile: Dictionary
var selected_asset: Node3D


func _ready():
	editor_label.text = 'NOTHING'
	play_button.set_disabled(true)
	save_button.set_disabled(true)
	delete_button.set_disabled(true)
	tiles_option_button.set_disabled(true)
	assets_option_button.set_disabled(true)
	players_option_button.set_disabled(true)
	enemies_option_button.set_disabled(true)
	civilians_option_button.set_disabled(true)
	assets.append_array(assets_scene.instantiate().get_children())


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
		delete_button.set_pressed(false)
	
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


func _on_main_menu_button_pressed():
	menu._on_main_menu_button_pressed()
	menu.toggle_visibility(true)
	
	queue_free()


func _on_play_button_pressed():
	editor_label.text = 'PLAYING'
	is_deleting = false
	selected = null
	selected_tile = {}
	selected_asset = null


func _on_save_button_pressed():
	editor_label.text = 'SAVING'
	var file = FileAccess.open(SAVED_LEVELS_FILE_PATH, FileAccess.READ_WRITE)
	var content = file.get_as_text()
	var count = content.count('->START') + 1
	content += '\n' + str(count) + '->START\n'
	
	var map_dimension = sqrt(map.tiles.size())
	for tile in map.tiles:
		var index = map_dimension * (tile.coords.x - 1) + (tile.coords.y - 1)
		if index > 0 and int(index) % int(map.get_side_dimension()) == 0:
			content += '\n'
		
		content += map.convert_tile_type_enum_to_initial(tile.tile_type)
	
	content += '\n' + str(count) + '->STOP\n'
	
	if map.tiles.any(func(tile): return tile.models.has('asset')):
		content += str(count) + '->ASSETS_START\n'
		
		for tile in map.tiles:
			var index = map_dimension * (tile.coords.x - 1) + (tile.coords.y - 1)
			if index > 0 and int(index) % int(map.get_side_dimension()) == 0:
				content += '\n'
			
			if tile.models.has('asset'):
				content += map.convert_asset_filename_to_initial(tile.models.asset.name)
			else:
				content += map.convert_asset_filename_to_initial(null)
		
		content += '\n' + str(count) + '->ASSETS_STOP\n'
	
	file.store_string(content)
	editor_label.text = 'MAP ' + str(count) + ' SAVED'


func _on_load_button_pressed():
	pass # Replace with function body.


func _on_delete_button_toggled(toggled_on):
	is_deleting = toggled_on
	if is_deleting:
		editor_label.text = 'DELETING'
	else:
		editor_label.text = 'NOTHING'
	
	selected = null
	selected_tile = {}
	selected_asset = null


func _on_maps_option_button_item_selected(index):
	is_deleting = false
	
	play_button.set_disabled(false)
	save_button.set_disabled(false)
	delete_button.set_disabled(false)
	maps_option_button.set_disabled(true)
	tiles_option_button.set_disabled(false)
	assets_option_button.set_disabled(false)
	players_option_button.set_disabled(false)
	enemies_option_button.set_disabled(false)
	civilians_option_button.set_disabled(false)
	
	map = map_scenes[index - 1].instantiate()
	add_child(map)
	
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
	maps_option_button.select(0)


func _on_tiles_option_button_item_selected(index):
	is_deleting = false
	selected = null
	selected_asset = null
	
	match index:
		1: selected_tile = {'color': Color('e3cdaa'), 'tile_type': TileType.PLAIN}
		2: selected_tile = {'color': Color('66ff3e'), 'tile_type': TileType.TREE}
	
	editor_label.text = 'SELECTED TILE ' + TileType.keys()[selected_tile.tile_type]
	tiles_option_button.select(0)


func _on_assets_option_button_item_selected(index):
	is_deleting = false
	selected = null
	selected_tile = {}
	
	match index:
		1: selected_asset = assets.filter(func(asset): return asset.name == 'sign').front().duplicate()
	
	editor_label.text = 'SELECTED ASSET ' + selected_asset.name
	assets_option_button.select(0)


func _on_players_option_button_item_selected(index):
	is_deleting = false
	selected_tile = {}
	selected_asset = null
	
	var player_instance = player_scenes[index - 1].instantiate()
	selected = player_instance
	
	editor_label.text = 'SELECTED ' + selected.name
	players_option_button.select(0)


func _on_enemies_option_button_item_selected(index):
	is_deleting = false
	selected_tile = {}
	selected_asset = null
	
	var enemy_instance = enemy_scenes[index - 1].instantiate()
	selected = enemy_instance
	
	editor_label.text = 'SELECTED ' + selected.name
	enemies_option_button.select(0)


func _on_civilians_option_button_item_selected(index):
	is_deleting = false
	selected_tile = {}
	selected_asset = null
	
	var civilian_instance = civilian_scenes[index - 1].instantiate()
	selected = civilian_instance
	
	editor_label.text = 'SELECTED ' + selected.name
	civilians_option_button.select(0)


func _on_editor_tile_clicked(tile):
	var character = tile.get_character()
	if not selected_tile.is_empty():
		tile.tile_type = selected_tile.tile_type
		tile.model_material.albedo_color = selected_tile.color
		editor_label.text = 'CHANGED TILE TYPE TO ' + TileType.keys()[selected_tile.tile_type] + ' ON TILE ' + str(tile.coords)
	elif selected or selected_asset:
		if character:
			selected = character
			selected_tile = {}
			selected_asset = null
			editor_label.text = 'SELECTED ' + selected.name
		elif tile.models.has('asset'):
			selected = null
			selected_tile = {}
			selected_asset = tile.models.asset
			editor_label.text = 'SELECTED ASSET ' + selected_asset.name
		else:
			var first_time
			if selected:
				if selected.tile:
					selected.tile.reset()
					first_time = false
				else:
					add_child(selected)
					first_time = true
				
				selected.tile = tile
				tile.set_character(selected)
				selected.position = Vector3(tile.position.x, 0.0, tile.position.z)
				editor_label.text = 'PLACED ' + selected.name + ' ON TILE ' + str(tile.coords)
				if first_time:
					selected = null
			elif selected_asset:
				if selected_asset.has_meta('tile'):
					var old_tile = map.tiles.filter(func(tile): return tile == selected_asset.get_meta('tile')).front()
					old_tile.models.asset.reparent(tile, false)
					old_tile.models.erase('asset')
					first_time = false
				else:
					tile.add_child(selected_asset)
					first_time = true
				
				selected_asset.set_meta('tile', tile)
				tile.models.asset = selected_asset
				editor_label.text = 'PLACED ASSET ' + selected_asset.name + ' ON TILE ' + str(tile.coords)
				if first_time:
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
