extends Util

@export var assets_scene: PackedScene

const TILE_1 = preload("res://Assets/loafbrr.basic-platforming-pack/Tiles/Textures/tile1.png")
const TILE_5 = preload("res://Assets/loafbrr.basic-platforming-pack/Tiles/Textures/tile5.png")
const OUTLINE_SHADER = preload("res://Other/outline_shader.gdshader")

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


func spawn(file_path, level):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var map_level_tiles = file.get_as_text().get_slice(str(level - 1) + '->START', 1).get_slice(str(level - 1) + '->STOP', 0).strip_escapes()
	
	var map_dimension = get_side_dimension()
	for tile in tiles:
		# file content index based on coords
		var index = map_dimension * (tile.coords.x - 1) + (tile.coords.y - 1)
		var map_level_tile
		if rmg:
			map_level_tile = TileType.values()[TileType.values().pick_random()]
		else:
			map_level_tile = convert_tile_type_initial_to_enum(map_level_tiles[index])
		
		var models = get_models_by_tile_type(map_level_tile)
		var health_type = get_health_type_by_tile_type(map_level_tile)
		var init_data = {
			'models': models,
			'tile_type': map_level_tile,
			'health_type': health_type,
		};
		
		tile.reset()
		tile.init(init_data)


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


func get_models_by_tile_type(tile_type):
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
			models.asset = assets.filter(func(asset): return asset.name == 'tree').front().duplicate()
		TileType.MOUNTAIN:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color('4e3214')#dark brown
			models.asset = assets.filter(func(asset): return asset.name == 'mountain').front().duplicate()
		TileType.VOLCANO:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color('4e3214')#dark brown
			models.asset = assets.filter(func(asset): return asset.name == 'volcano').front().duplicate()
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


func get_health_type_by_tile_type(tile_type):
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
