extends Node

class_name ActionObject

var id: Util.ActionType
var action_name: String
#var direction: Util.ActionDirection
var damage: int
var min_distance: int
var max_distance: int
var is_upgraded: bool
var description: String
var change_info: String
var textures: Array[CompressedTexture2D]


func init_from_action_data(action_data: Dictionary) -> void:
	id = action_data.id
	action_name = action_data.action_name
	damage = action_data.damage
	min_distance = action_data.min_distance
	max_distance = action_data.max_distance
	is_upgraded = action_data.is_upgraded
	description = action_data.description
	change_info = action_data.change_info
	textures = action_data.textures


func upgrade() -> void:
	match id:
		Util.ActionType.PUSH_BACK:
			damage += 1
		Util.ActionType.TOWARDS_AND_PUSH_BACK:
			damage += 1
		Util.ActionType.PULL_FRONT:
			damage += 1
		Util.ActionType.PULL_TOGETHER:
			damage += 1
		Util.ActionType.MISS_MOVE:
			max_distance += 1
		Util.ActionType.MISS_ACTION:
			max_distance += 1
		Util.ActionType.HIT_ALLY:
			max_distance += 1
		Util.ActionType.GIVE_SHIELD:
			max_distance += 1
		Util.ActionType.SLOW_DOWN:
			max_distance += 1
		Util.ActionType.CROSS_PUSH_BACK:
			damage += 1
		_: pass
	is_upgraded = true
