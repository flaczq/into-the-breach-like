extends Node

class_name ItemObject

var id: int
var cost: int
var available: bool


func init_from_item_data(item_data: Dictionary) -> void:
	id = item_data.id
	cost = item_data.cost
	available = item_data.available
