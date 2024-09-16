extends Util

#@onready var trees_assets = $TreesAssets
@export var assets_scene: PackedScene

var tiles: Array[Node] = []
var assets_tiles: Array[MeshInstance3D] = []
var assets_trees: Array[MeshInstance3D] = []
# random map generation
var rmg: bool = false


func _ready():
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
		
		var tile_health_type = get_health_type_by_tile_type(map_level_tile)
		var tile_default_color = get_model_default_color_by_tile_type(map_level_tile)
		var tile_asset = get_asset_by_tile_type(map_level_tile)
		var tile_init_data = {
			#'model': assets_tiles[0].duplicate(),
			'tile_type': map_level_tile,
			'health_type': tile_health_type,
			'model_default_color': tile_default_color,
			'asset': tile_asset
		};
		
		tile.reset()
		tile.init(tile_init_data)


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


func get_model_default_color_by_tile_type(tile_type):
	match tile_type:
		TileType.PLAIN:
			return Color.PALE_GOLDENROD
		TileType.GRASS:
			return Color.YELLOW_GREEN
		TileType.TREE:
			return Color.DARK_GREEN
		TileType.MOUNTAIN:
			return Color.RED
		TileType.WATER:
			return Color.DODGER_BLUE
		TileType.LAVA:
			return Color.ORANGE
		_:
			print('unknown tile type: ' + str(tile_type))
			return Color.PALE_GOLDENROD


func get_health_type_by_tile_type(tile_type):
	match tile_type:
		TileType.PLAIN:
			return TileHealthType.HEALTHY
		TileType.GRASS:
			return TileHealthType.HEALTHY
		TileType.TREE:
			return TileHealthType.INDESTRUCTIBLE
		TileType.MOUNTAIN:
			return TileHealthType.INDESTRUCTIBLE
		TileType.WATER:
			return TileHealthType.INDESTRUCTIBLE
		TileType.LAVA:
			return TileHealthType.INDESTRUCTIBLE
		_:
			print('unknown tile type: ' + str(tile_type))
			return TileHealthType.HEALTHY


func get_asset_by_tile_type(tile_type):
	match tile_type:
		TileType.TREE:
			var tree = assets_trees.filter(func(asset_tree): return asset_tree.name == 'roundTree01Small')
			if not tree.is_empty():
				return tree.front().duplicate()
		TileType.MOUNTAIN:
			# TODO
			return null
		_:
			return null


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
