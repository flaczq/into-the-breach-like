extends Util

@export var assets_scene: PackedScene

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
	for tile in tiles:
		# file content index based on coords
		var index = get_side_dimension() * (tile.coords.x - 1) + (tile.coords.y - 1)
		var tile_type = convert_tile_type_initial_to_enum(level_data.tiles[index])
		var asset_filename = convert_asset_initial_to_filename(level_data.tiles_assets[index])
		var models = get_models_by_tile_type(tile_type, asset_filename, level_data.level_type, level_data.level)
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
			print('[convert_tile_type_initial_to_enum] -> unknown tile type initial: ' + tile_type_initial)
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
			print('[convert_tile_type_enum_to_initial] -> unknown tile type enum: ' + str(tile_type_enum))
			return 'P'


# maybe change this to enum?
func convert_asset_initial_to_filename(asset_initial):
	match asset_initial:
		'0': return null
		'T': return 'tree'
		'M': return 'mountain'
		'V': return 'volcano'
		'S': return 'sign'
		'I': return 'indicator-special-cross'
		_:
			print('[convert_asset_initial_to_filename] -> unknown asset initial: ' + asset_initial)
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
	
	if asset_filename.begins_with('indicator-special-cross'):
		return 'I'
	
	print('[convert_asset_filename_to_initial] -> default asset used or unknown asset filename: ' + asset_filename)
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
	
	if models.get('asset'):
		for child in models.asset.get_children().filter(func(child): return child.is_in_group('OUTLINES')):
			models.asset_outline = child
	
	models.tile_default_color = get_color_by_tile_type(tile_type)
	
	return models


func get_color_by_tile_type(tile_type):
	match tile_type:
		TileType.PLAIN:
			return Color('e3cdaa')#light brown
		TileType.GRASS:
			return Color('66ff3e')#green
		TileType.TREE:
			return Color('66ff3e')#green
		TileType.MOUNTAIN:
			return Color('4e3214')#dark brown
		TileType.VOLCANO:
			return Color('4e3214')#dark brown
		TileType.WATER:
			return Color('3a8aff')#blue
		TileType.LAVA:
			return Color('c54700')#orange
		_:
			print('[get_color_by_tile_type] -> unknown tile type: ' + str(tile_type))
			return Color('e3cdaa')


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
			print('[get_health_type_by_tile_type] -> unknown tile type: ' + str(tile_type))
			return TileHealthType.HEALTHY


func plan_level_events(level_events):
	for level_event in level_events:
		print(LevelEvent.keys()[level_event])
		# missle spawned at random tile
		if level_event == LevelEvent.FALLING_MISSLE:
			var event_asset = assets.filter(func(asset): return asset.name == 'indicator-special-cross').front().duplicate()
			var event_asset_material = StandardMaterial3D.new()
			event_asset_material.albedo_color = Color('FF0000')#red
			event_asset.set_surface_override_material(0, event_asset_material)
			
			#var max_range = (2) if (get_side_dimension() == 8 or get_side_dimension() == 6) else (1)
			for i in range(0, 1):
				var event_tile = get_untargetable_tiles().pick_random()
				event_tile.models.event_asset = event_asset.duplicate()
				event_tile.models.event_asset.add_to_group('MISSLES_INDICATORS')
				event_tile.models.event_asset.show()
				event_tile.add_child(event_tile.models.event_asset)
				print('spawned missle at ' + str(event_tile.coords))
		# rock spawned near mountains
		elif level_event == LevelEvent.FALLING_ROCK:
			var mountains_coords = tiles.filter(func(tile): return tile.tile_type == TileType.MOUNTAIN).map(func(tile): return tile.coords)
			var event_asset = assets.filter(func(asset): return asset.name == 'indicator-special-cross').front().duplicate()
			var event_asset_material = StandardMaterial3D.new()
			event_asset_material.albedo_color = Color('7A5134')#brown
			event_asset.set_surface_override_material(0, event_asset_material)
			
			#var max_range = (3) if (get_side_dimension() == 8) else (2) if (get_side_dimension() == 6) else (1)
			for i in range(0, 1):
				var event_tiles = get_untargetable_tiles().filter(func(tile): return not mountains_coords.has(tile.coords) and mountains_coords.any(func(mountain_coords): return are_tiles_close(mountain_coords, tile.coords, 2.5)))
				print(event_tiles.map(func(tile): return str(tile.coords)))
				var event_tile = event_tiles.pick_random()
				event_tile.models.event_asset = event_asset.duplicate()
				event_tile.models.event_asset.add_to_group('ROCKS_INDICATORS')
				event_tile.models.event_asset.show()
				event_tile.add_child(event_tile.models.event_asset)
				print('spawned rock at ' + str(event_tile.coords))
		#TODO else...


func execute_level_events(level_events):
	for level_event in level_events:
		# missles hit at spawned indicators
		if level_event == LevelEvent.FALLING_MISSLE:
			for tile in tiles.filter(func(tile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('MISSLES_INDICATORS')):
				await tile.get_shot(1)
				tile.models.event_asset.queue_free()
				tile.models.erase('event_asset')
		# rocks hit at spawned indicators
		elif level_event == LevelEvent.FALLING_ROCK:
			for tile in tiles.filter(func(tile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('ROCKS_INDICATORS')):
				await tile.get_shot(1)
				tile.models.event_asset.queue_free()
				tile.models.erase('event_asset')
		#TODO else...


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


func get_targetable_tiles():
	return tiles.filter(func(tile): return is_instance_valid(tile.models.get('asset')) and not tile.models.asset.is_queued_for_deletion() and tile.models.asset.is_in_group('TARGETABLES'))


func get_untargetable_tiles():
	return tiles.filter(func(tile): return not get_targetable_tiles().has(tile) and (not tile.models.has('event_asset') or not tile.models.event_asset.is_in_group('EVENTS_INDICATORS')))
