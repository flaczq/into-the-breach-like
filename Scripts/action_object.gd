extends Node

class_name ActionObject

var id: Util.ActionType
var action_name: String
#var direction: Util.ActionDirection
var damage: int
var min_distance: int
var max_distance: int
var description: String
var textures: Array[CompressedTexture2D]


func init_from_item_data(action_data: Dictionary) -> void:
	id = action_data.id
	action_name = action_data.action_name
	damage = action_data.damage
	min_distance = action_data.min_distance
	max_distance = action_data.max_distance
	description = action_data.description
	textures = action_data.textures
