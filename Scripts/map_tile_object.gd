extends Util

class_name MapTileObject

var models: Dictionary
var tile_type: TileType
var health_type: TileHealthType


func init(new_models: Dictionary, new_tile_type: TileType, new_health_type: TileHealthType) -> void:
	models = new_models
	tile_type = new_tile_type
	health_type = new_health_type