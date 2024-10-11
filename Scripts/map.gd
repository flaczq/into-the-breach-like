extends Util

@export var assets_scene: PackedScene

const TILE_1: Resource = preload('res://Assets/loafbrr.basic-platforming-pack/Tiles/Textures/tile1.png')
const TILE_5: Resource = preload('res://Assets/loafbrr.basic-platforming-pack/Tiles/Textures/tile5.png')
const FLASHING_SHADER: Resource = preload('res://Other/flashing_shader.gdshader')
const OUTLINE_SHADER: Resource = preload('res://Other/outline_shader.gdshader')

var tiles: Array[Node3D] = []
var assets: Array[Node3D] = []


func _ready():
	name = name + '_' + str(randi())
	
	for child in get_children().filter(func(child): return child.is_in_group('TILES')):
		tiles.push_back(child)
	
	assets.append_array(assets_scene.instantiate().get_children())


func spawn(level_data):
	var map_dimension = get_side_dimension()
	
	for tile in tiles:
		# file content index based on coords
		var index = map_dimension * (tile.coords.x - 1) + (tile.coords.y - 1)
		var tile_type = convert_tile_type_initial_to_enum(level_data.map.tiles[index])
		var asset_filename = convert_asset_initial_to_filename(level_data.map.tiles_assets[index])
		var models = get_models_by_tile_type(tile_type, asset_filename, level_data.map.level_type, level_data.map.level)
		var health_type = get_health_type_by_tile_type(tile_type, asset_filename)
		var tile_init_data = {
			'models': models,
			'tile_type': tile_type,
			'health_type': health_type,
		};
		
		tile.reset()
		tile.init(tile_init_data)


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
			print('unknown tile type initial: ' + tile_type_initial)
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
			print('unknown tile type enum: ' + str(tile_type_enum))
			return 'P'


func convert_asset_initial_to_filename(asset_initial):
	match asset_initial:
		'0': return null
		'T': return 'tree'
		'M': return 'mountain'
		'V': return 'volcano'
		'S': return 'sign'
		_:
			print('unknown asset initial: ' + asset_initial)
			return null


func convert_asset_filename_to_initial(asset_filename):
	if not asset_filename:
		return '0'
	
	if asset_filename.begins_with('tree'):
		return 'T'
	
	if asset_filename.begins_with('mountain'):
		return 'M'
	
	if asset_filename.begins_with('volcano'):
		return 'V'
	
	if asset_filename.begins_with('sign'):
		return 'S'
	
	print('default asset used or unknown asset filename: ' + asset_filename)
	return '0'


func get_models_by_tile_type(tile_type, asset_filename, level_type, level):
	var models = {'tile_shader': FLASHING_SHADER}
	
	for asset in assets:
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
		
		if asset_filename and asset.name == asset_filename:
			models.asset = asset.duplicate()
			
			# change name for custom translations
			if models.asset.name == 'sign' and level_type == LevelType.TUTORIAL:
				models.asset.name += '_' + LevelType.keys()[level_type] + '_' + str(level)
	
	if models.has('asset'):
		for child in models.asset.get_children():
			if child.is_in_group('MODEL_OUTLINES'):
				models.asset_outline = child
	
	match tile_type:
		TileType.PLAIN:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color('e3cdaa')#light brown
		TileType.GRASS:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color('66ff3e')#green
		TileType.TREE:
			#models.tile_texture = TILE_1
			models.tile_default_color = Color('66ff3e')#green
		TileType.MOUNTAIN:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color('4e3214')#dark brown
		TileType.VOLCANO:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color('4e3214')#dark brown
		TileType.WATER:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color('3a8aff')#blue
		TileType.LAVA:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color('c54700')#orange
		_:
			print('unknown tile type: ' + str(tile_type))
			#models.tile_texture = TILE_5
			models.tile_default_color = Color('e3cdaa')
	
	return models


func get_health_type_by_tile_type(tile_type, asset_filename):
	# hardcoded
	if asset_filename:
		if asset_filename == 'tree' or asset_filename == 'sign':
			return TileHealthType.DESTRUCTIBLE
		
		if asset_filename == 'mountain' or asset_filename == 'volcano':
			return TileHealthType.INDESTRUCTIBLE
	
	match tile_type:
		TileType.PLAIN: return TileHealthType.HEALTHY
		TileType.GRASS: return TileHealthType.HEALTHY
		TileType.TREE: return TileHealthType.HEALTHY
		TileType.MOUNTAIN: return TileHealthType.INDESTRUCTIBLE
		TileType.VOLCANO: return TileHealthType.INDESTRUCTIBLE
		TileType.WATER: return TileHealthType.INDESTRUCTIBLE_WALKABLE
		TileType.LAVA: return TileHealthType.INDESTRUCTIBLE_WALKABLE
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


func get_spawnable_tiles(tiles_coords):
	if tiles_coords.is_empty():
		return get_available_tiles()
	
	var vector2i_tiles_coords = tiles_coords.map(func(tile_coords): return Vector2i(tile_coords.x, tile_coords.y))
	var spawnable_tiles = get_available_tiles().filter(func(tile): return vector2i_tiles_coords.has(tile.coords))
	if spawnable_tiles.is_empty():
		return get_available_tiles()
	
	return spawnable_tiles
