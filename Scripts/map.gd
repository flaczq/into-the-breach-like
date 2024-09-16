extends Util

@onready var trees_assets = $TreesAssets

var tiles: Array[Node] = []


func _ready():
	for child in get_children():
		if child.is_in_group('TILES'):
			tiles.push_back(child)


func spawn(file_path, level):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var map_level_tiles = file.get_as_text().get_slice(str(level - 1) + '->START', 1).get_slice(str(level - 1) + '->STOP', 0).strip_escapes()
	
	var map_dimension = get_side_dimension()
	for tile in tiles:
		# file content index based on coords
		var index = map_dimension * (tile.coords.x - 1) + (tile.coords.y - 1)
		var map_level_tile
		# DEBUG
		# random map generation
		if true:
			map_level_tile = map_level_tiles[index]
		
		tile.reset()
		# tile needs an asset
		if true:
			for tree in trees_assets.get_children():
				if tree.name == 'pineSmall':
					tree.show()
				else:
					tree.hide()
		tile.set_tile_type(map_level_tile, trees_assets.duplicate())
	
	trees_assets.queue_free()


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
