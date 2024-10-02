extends Util

@export var assets_scene: PackedScene

const TUTORIAL_MAPS_FILE_PATH: String = 'res://Data/tutorial_maps.txt'
const ABC_MAPS_FILE_PATH: String = 'res://Data/abc_maps.txt'
const TILE_1: Resource = preload('res://Assets/loafbrr.basic-platforming-pack/Tiles/Textures/tile1.png')
const TILE_5: Resource = preload('res://Assets/loafbrr.basic-platforming-pack/Tiles/Textures/tile5.png')
const OUTLINE_SHADER: Resource = preload('res://Other/outline_shader.gdshader')

var tiles: Array[Node] = []
var assets: Array[Node] = []
# random map generation
var rmg: bool = false


func _ready():
	name = name + '_' + str(randi())
	
	for child in get_children().filter(func(child): return child.is_in_group('TILES')):
		tiles.push_back(child)
	
	var assets_instance = assets_scene.instantiate()
	assets = assets_instance.get_children()


func spawn(map_type, level):
	var file_path = get_map_file_path(map_type)
	var file = FileAccess.open(file_path, FileAccess.READ)
	var map_level = get_map_level(map_type, level)
	var map_level_tiles = file.get_as_text().get_slice(str(map_level) + '->START', 1).get_slice(str(map_level) + '->STOP', 0).strip_escapes()
	var map_level_tile_assets = file.get_as_text().get_slice(str(map_level) + '->ASSETS_START', 1).get_slice(str(map_level) + '->ASSETS_STOP', 0).strip_escapes()
	
	var map_dimension = get_side_dimension()
	for tile in tiles:
		# file content index based on coords
		var index = map_dimension * (tile.coords.x - 1) + (tile.coords.y - 1)
		var map_level_tile
		if rmg:
			map_level_tile = TileType.values()[TileType.values().pick_random()]
		else:
			map_level_tile = convert_tile_type_initial_to_enum(map_level_tiles[index])
		
		var asset_filename = convert_asset_initial_to_filename(map_level_tile_assets[index])
		
		var models = get_models_by_tile_type(map_level_tile, asset_filename, map_level)
		var health_type = get_health_type_by_tile_type(map_level_tile, asset_filename)
		var init_data = {
			'models': models,
			'tile_type': map_level_tile,
			'health_type': health_type,
		};
		
		tile.reset()
		tile.init(init_data)


func get_map_file_path(map_type):
	match map_type:
		MapType.TUTORIAL: return TUTORIAL_MAPS_FILE_PATH
		MapType.ABC: return ABC_MAPS_FILE_PATH
		_:
			print('unknown map type: ' + map_type)
			return TUTORIAL_MAPS_FILE_PATH


func get_map_level(map_type, level):
	if map_type == MapType.TUTORIAL:
		return level
	
	# FIXME
	return randi_range(1, 2)


func convert_tile_type_initial_to_enum(tile_type_initial):
	match tile_type_initial:
		'P': return TileType.PLAIN
		'G': return TileType.GRASS
		'T': return TileType.TREE
		'M': return TileType.MOUNTAIN
		'V': return TileType.VOLCANO
		'W': return TileType.WATER
		'L': return TileType.LAVA
		_:
			print('unknown tile type: ' + tile_type_initial)
			return TileType.PLAIN


func convert_tile_type_enum_to_initial(tile_type_enum):
	match tile_type_enum:
		TileType.PLAIN: return 'P'
		TileType.GRASS: return 'G'
		TileType.TREE: return 'T'
		TileType.MOUNTAIN: return 'M'
		TileType.VOLCANO: return 'V'
		TileType.WATER: return 'W'
		TileType.LAVA: return 'L'
		_:
			print('unknown tile type: ' + str(tile_type_enum))
			return 'P'


func convert_asset_initial_to_filename(asset_initial):
	match asset_initial:
		'0': return null
		'S': return 'small-sign1_001'
		_:
			print('unknown asset: ' + asset_initial)
			return null


func get_models_by_tile_type(tile_type, asset_filename, level):
	var models = {'tile_shader': OUTLINE_SHADER}
	
	for asset in assets:
		# has to be duplicated to make them unique
		if asset.name == 'ground_grass':
			models.tile = asset.duplicate()
		elif asset.name == 'TileHighlighted':
			models.tile_highlighted = asset.duplicate()
		elif asset.name == 'TileTargeted':
			models.tile_targeted = asset.duplicate()
		elif asset.name == 'TileDamaged':
			models.tile_damaged = asset.duplicate()
		elif asset.name == 'TileDestroyed':
			models.tile_destroyed = asset.duplicate()
		elif asset.name == 'indicator-square-a':
			models.indicator_solid = asset.duplicate()
		elif asset.name == 'indicator-square-b':
			models.indicator_dashed = asset.duplicate()
		elif asset.name == 'indicator-square-c':
			models.indicator_corners = asset.duplicate()
		
		# additional asset has priority over standard tile asset
		if asset_filename:
			if asset.name == asset_filename:
				models.asset = asset.duplicate()
				models.asset.name = 'sign_' + str(level)
		elif tile_type == TileType.TREE:
			if asset.name == 'tree':
				models.asset = asset.duplicate()
		elif tile_type == TileType.MOUNTAIN:
			if asset.name == 'mountain':
				models.asset = asset.duplicate()
		elif tile_type == TileType.VOLCANO:
			if asset.name == 'volcano':
				models.asset = asset.duplicate()
	
	match tile_type:
		TileType.PLAIN:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color('e3cdaa')#light brown
		TileType.GRASS:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color.SEA_GREEN
		TileType.TREE:
			#models.tile_texture = TILE_1
			models.tile_default_color = Color('60b30a')#green
		TileType.MOUNTAIN:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color('4e3214')#dark brown
		TileType.VOLCANO:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color('4e3214')#dark brown
		TileType.WATER:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color.DODGER_BLUE
		TileType.LAVA:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color.ORANGE
		_:
			print('unknown tile type: ' + str(tile_type))
			#models.tile_texture = TILE_5
			models.tile_default_color = Color.PALE_GOLDENROD
	
	return models


func get_health_type_by_tile_type(tile_type, asset_filename):
	# all additional assets are destructible
	if asset_filename:
		return TileHealthType.DESTRUCTIBLE
	
	match tile_type:
		TileType.PLAIN: return TileHealthType.HEALTHY
		TileType.GRASS: return TileHealthType.HEALTHY
		TileType.TREE: return TileHealthType.DESTRUCTIBLE
		TileType.MOUNTAIN: return TileHealthType.INDESTRUCTIBLE
		TileType.VOLCANO: return TileHealthType.INDESTRUCTIBLE
		TileType.WATER: return TileHealthType.INDESTRUCTIBLE
		TileType.LAVA: return TileHealthType.INDESTRUCTIBLE
		_:
			print('unknown tile type: ' + str(tile_type))
			return TileHealthType.HEALTHY


func get_side_dimension():
	return sqrt(tiles.size())


func get_horizontal_diagonal_dimension(coords):
	return get_side_dimension() - absi(get_side_dimension() + 1 - (coords.x + coords.y))


func get_vertical_diagonal_dimension(coords):
	return get_side_dimension() - absi(coords.x - coords.y)


func get_available_tiles():
	return tiles.filter(func(tile): return tile.is_free())


func get_occupied_tiles():
	return tiles.filter(func(tile): return not tile.is_free())


func get_spawnable_tiles(tiles_coords):
	if tiles_coords.is_empty():
		return get_available_tiles()
	
	return get_available_tiles().filter(func(tile): return tiles_coords.has(tile.coords))
