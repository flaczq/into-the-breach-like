extends Util

class_name Map

@export var assets_scene: PackedScene

const FLASHING_SHADER: Resource = preload('res://Other/flashing_shader.gdshader')
const OUTLINE_SHADER: Resource = preload('res://Other/outline_shader.gdshader')

var tiles: Array[MapTile] = []
var assets: Array[Node3D] = []


func _ready() -> void:
	name = name + '_' + str(randi())
	
	for child in get_children().filter(func(child): return child.is_in_group('TILES')):
		tiles.push_back(child)
	
	assets.append_array(assets_scene.instantiate().get_children())


func spawn(level_data: Dictionary) -> void:
	assert(level_data.has('tiles'), 'Set tiles for level_data')
	assert(level_data.has('tiles_assets'), 'Set tiles_assets for level_data')
	assert(level_data.has('level_type'), 'Set level_type for level_data')
	assert(level_data.has('level'), 'Set level for level_data')
	for tile in tiles:
		# file content index based on coords
		var index = get_side_dimension() * (tile.coords.x - 1) + (tile.coords.y - 1)
		var tile_type = convert_tile_type_initial_to_enum(level_data.tiles[index])
		var asset_filename = convert_asset_initial_to_filename(level_data.tiles_assets[index])
		var models = get_models_by_tile_type(tile_type, asset_filename, level_data.level_type, level_data.level)
		var health_type = get_health_type_by_tile_type(tile_type, asset_filename)
		var points = get_points_by_tile_type(tile_type, asset_filename)
		var map_tile_object: MapTileObject = MapTileObject.new()
		map_tile_object.init(models, tile_type, health_type, points)
		
		tile.reset()
		tile.init(map_tile_object)


func convert_tile_type_initial_to_enum(tile_type_initial: String) -> TileType:
	match tile_type_initial:
		'P': return TileType.PLAIN
		'G': return TileType.GRASS
		'T': return TileType.TREE
		'M': return TileType.MOUNTAIN
		'V': return TileType.VOLCANO
		'W': return TileType.WATER
		'L': return TileType.LAVA
		'F': return TileType.FLOOR
		'H': return TileType.HOLE
		_:
			print('[convert_tile_type_initial_to_enum] -> unknown tile type initial: ' + tile_type_initial)
			return TileType.PLAIN


func convert_tile_type_enum_to_initial(tile_type_enum: TileType) -> String:
	match tile_type_enum:
		TileType.PLAIN: return 'P'
		TileType.GRASS: return 'G'
		TileType.TREE: return 'T'
		TileType.MOUNTAIN: return 'M'
		TileType.VOLCANO: return 'V'
		TileType.WATER: return 'W'
		TileType.LAVA: return 'L'
		TileType.FLOOR: return 'F'
		TileType.HOLE: return 'H'
		_:
			print('[convert_tile_type_enum_to_initial] -> unknown tile type enum: ' + str(tile_type_enum))
			return 'P'


# maybe change this to enum?
func convert_asset_initial_to_filename(asset_initial: String) -> String:
	match asset_initial:
		'0': return ''
		'T': return 'tree'
		'M': return 'mountain'
		'V': return 'volcano'
		'S': return 'sign'
		'I': return 'indicator-special-cross'
		'H': return 'house'
		_:
			print('[convert_asset_initial_to_filename] -> unknown asset initial: ' + asset_initial)
			return ''


func convert_asset_filename_to_initial(asset_filename: String) -> String:
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
	
	if asset_filename.begins_with('indicator-special-cross'):
		return 'I'
	
	if asset_filename.begins_with('house'):
		return 'H'
	
	print('[convert_asset_filename_to_initial] -> default asset used or unknown asset filename: ' + asset_filename)
	return '0'


func get_models_by_tile_type(tile_type: TileType, asset_filename: String, level_type: LevelType, level: int) -> Dictionary:
	var models = {
		'tile_shader': FLASHING_SHADER,
		'tile_texture': null,
		'asset': null,
		'asset_outline': null,
		'asset_damaged': null,
		'asset_damaged_outline': null,
		'event_asset': null
	}
	
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
		elif asset.name == 'tile-text':
			models.tile_text = asset.duplicate()
			models.tile_text.mesh = asset.mesh.duplicate()
		elif asset.name == 'indicator-square-a':
			models.indicator_solid = asset.duplicate()
		elif asset.name == 'indicator-square-b':
			models.indicator_dashed = asset.duplicate()
		elif asset.name == 'indicator-square-c':
			models.indicator_corners = asset.duplicate()
		
		if asset.name == asset_filename:
			models.asset = asset.duplicate()
			
			var assets_damaged = assets.filter(func(asset): return asset.name == asset_filename + '_damaged')
			if assets_damaged.is_empty():
				models.asset_damaged = asset.duplicate()
			else:
				models.asset_damaged = assets_damaged.front().duplicate()
			
			# change name for custom translations
			if models.asset.name == 'sign' and level_type == LevelType.TUTORIAL:
				models.asset.name += '_' + LevelType.keys()[level_type] + '_' + str(level)
				models.asset_damaged.name += '_' + LevelType.keys()[level_type] + '_' + str(level)
	
	if models.asset:
		for child in models.asset.get_children():
			if child.is_in_group('OUTLINES'):
				models.asset_outline = child
	if models.asset_damaged:
		for child in models.asset_damaged.get_children():
			if child.is_in_group('OUTLINES'):
				models.asset_damaged_outline = child
	
	models.tile_default_color = get_color_by_tile_type(tile_type)
	
	return models


func get_color_by_tile_type(tile_type: TileType) -> Color:
	match tile_type:
		TileType.PLAIN:
			return Color('e3cdaa')#beige
		TileType.GRASS:
			return Color('0cae5b')#dark green
		TileType.TREE:
			return Color('0cae5b')#dark green
		TileType.MOUNTAIN:
			return Color('4e3214')#dark brown
		TileType.VOLCANO:
			return Color('4e3214')#dark brown
		TileType.WATER:
			return Color('3a8aff')#blue
		TileType.LAVA:
			return Color('c54700')#orange
		TileType.FLOOR:
			return Color('b58450')#light brown
		TileType.HOLE:
			return Color('010101')#black
		_:
			print('[get_color_by_tile_type] -> unknown tile type: ' + str(tile_type))
			return Color('e3cdaa')


func get_health_type_by_tile_type(tile_type: TileType, asset_filename: String) -> TileHealthType:
	# FIXME hardcoded
	if asset_filename:
		if asset_filename == 'house':
			return TileHealthType.DESTRUCTIBLE_HEALTHY
		
		if asset_filename == 'tree' or asset_filename == 'sign':
			return TileHealthType.DESTRUCTIBLE_DAMAGED
		
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
		TileType.FLOOR: return TileHealthType.HEALTHY
		TileType.HOLE: return TileHealthType.DESTROYED
		_:
			print('[get_health_type_by_tile_type] -> unknown tile type: ' + str(tile_type))
			return TileHealthType.HEALTHY


func get_points_by_tile_type(tile_type: TileType, asset_filename: String) -> int:
	# FIXME hardcoded
	if asset_filename:
		if asset_filename == 'house':
			return 5
		
		if asset_filename == 'tree' or asset_filename == 'sign':
			return 2
		
		if asset_filename == 'mountain' or asset_filename == 'volcano':
			return 0
	
	match tile_type:
		TileType.PLAIN: return 1
		TileType.GRASS: return 1
		TileType.TREE: return 1
		TileType.MOUNTAIN: return 0
		TileType.VOLCANO: return 0
		TileType.WATER: return 0
		TileType.LAVA: return 0
		TileType.FLOOR: return 1
		TileType.HOLE: return -1
		_:
			print('[get_points_by_tile_type] -> unknown tile type: ' + str(tile_type))
			return 0


func get_side_dimension() -> int:
	return sqrt(tiles.size())


func get_horizontal_diagonal_dimension(coords: Vector2i) -> int:
	return get_side_dimension() - absi(get_side_dimension() + 1 - (coords.x + coords.y))


func get_vertical_diagonal_dimension(coords: Vector2i) -> int:
	return get_side_dimension() - absi(coords.x - coords.y)


func get_available_tiles() -> Array[MapTile]:
	return tiles.filter(func(tile: MapTile): return tile.is_free())


func get_spawnable_tiles(tiles_coords: Array) -> Array[MapTile]:
	if tiles_coords.is_empty():
		return get_available_tiles()
	
	var vector2i_tiles_coords = convert_spawn_coords_to_vector_coords(tiles_coords)
	var spawnable_tiles = get_available_tiles().filter(func(tile: MapTile): return vector2i_tiles_coords.has(tile.coords))
	if spawnable_tiles.is_empty():
		return get_available_tiles()
	
	return spawnable_tiles


func get_targetable_tiles() -> Array[MapTile]:
	# add asset to group 'TARGETABLES' to make the enemy try to target it
	return tiles.filter(func(tile: MapTile): return (is_instance_valid(tile.models.get('asset')) and not tile.models.asset.is_queued_for_deletion() and tile.models.asset.is_in_group('TARGETABLES')) \
		or (is_instance_valid(tile.models.get('asset_damaged')) and not tile.models.asset_damaged.is_queued_for_deletion() and tile.models.asset_damaged.is_in_group('TARGETABLES')))


func get_untargetable_tiles() -> Array[MapTile]:
	return tiles.filter(func(tile: MapTile): return not get_targetable_tiles().has(tile) and (not tile.models.get('event_asset') or not tile.models.event_asset.is_in_group('EVENTS_INDICATORS')))
