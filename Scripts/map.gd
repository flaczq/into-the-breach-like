extends Util

@export var assets_scene: PackedScene

const TILE_1 = preload("res://Assets/loafbrr.basic-platforming-pack/Tiles/Textures/tile1.png")
const TILE_5 = preload("res://Assets/loafbrr.basic-platforming-pack/Tiles/Textures/tile5.png")
const OUTLINE_SHADER = preload("res://Other/outline_shader.gdshader")

var tiles: Array[Node] = []
var assets_tiles: Array[MeshInstance3D] = []
var assets_trees: Array[MeshInstance3D] = []
# random map generation
var rmg: bool = false


func _ready():
	name = name + '_' + str(randi())
	
	for child in get_children().filter(func(child): return child.is_in_group('TILES')):
		tiles.push_back(child)
	
	var assets = assets_scene.instantiate()
	for assets_child in assets.get_children():
		if assets_child.is_in_group('ASSETS_TILES'):
			assets_tiles.append_array(assets_child.get_children())
		
		if assets_child.is_in_group('ASSETS_TREES'):
			assets_trees.append_array(assets_child.get_children())


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
		TileType.WATER: return 'W'
		TileType.LAVA: return 'L'
		_:
			print('unknown tile type: ' + str(tile_type_enum))
			return 'P'


func get_models_by_tile_type(tile_type):
	var models = {'tile_shader': OUTLINE_SHADER}
	
	MeshInstance3D
	for assets_tile in assets_tiles:
		# has to be duplicated to make them unique
		if assets_tile.name == 'ground_grass':
			models.tile = assets_tile.duplicate()
		elif assets_tile.name == 'TileHighlighted':
			models.tile_highlighted = assets_tile.duplicate()
		elif assets_tile.name == 'TileTargeted':
			models.tile_targeted = assets_tile.duplicate()
		elif assets_tile.name == 'TileDamaged':
			models.tile_damaged = assets_tile.duplicate()
		elif assets_tile.name == 'TileDestroyed':
			models.tile_destroyed = assets_tile.duplicate()
		elif assets_tile.name == 'indicator-square-a':
			models.indicator_solid = assets_tile.duplicate()
		elif assets_tile.name == 'indicator-square-b':
			models.indicator_dashed = assets_tile.duplicate()
		elif assets_tile.name == 'indicator-square-c':
			models.indicator_corners = assets_tile.duplicate()
	
	match tile_type:
		TileType.PLAIN:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color.PALE_GOLDENROD
		TileType.GRASS:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color.SEA_GREEN
		TileType.TREE:
			#models.tile_texture = TILE_1
			models.tile_default_color = Color.DARK_GREEN
			models.asset = assets_trees.filter(func(asset_tree): return asset_tree.name == 'Trees_004').front().duplicate()
		TileType.MOUNTAIN:
			#models.tile_texture = TILE_5
			models.tile_default_color = Color.FIREBRICK
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
