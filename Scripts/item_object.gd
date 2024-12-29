extends Node

class_name ItemObject

var id: Util.ItemType
var item_name: String
var cost: int
var available: bool
var texture: CompressedTexture2D


func init_from_item_data(item_data: Dictionary) -> void:
	id = item_data.id
	item_name = item_data.item_name
	cost = item_data.cost
	available = item_data.available
	texture = item_data.texture
