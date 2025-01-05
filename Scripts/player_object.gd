extends Node

class_name PlayerObject

var id: Util.PlayerType
var model_name: String
var max_health: int
var damage: int
var move_distance: int
var action_min_distance: int
var action_max_distance: int
var action_direction: Util.ActionDirection
var action_type: Util.ActionType
var action_damage: int
var passive_type: Util.PassiveType
var can_fly: bool
var state_types: Array[Util.StateType]
var items_ids: Array[Util.ItemType]
var texture: CompressedTexture2D


func init_from_player_data(player_data: Dictionary) -> void:
	# id = scene, because scene: 0 is tutorial player
	id = player_data.id
	# TODO custom name
	model_name = player_data.model_name
	max_health = player_data.max_health
	damage = player_data.damage
	move_distance = player_data.move_distance
	action_min_distance = player_data.action_min_distance
	action_max_distance = player_data.action_max_distance
	action_direction = player_data.action_direction
	action_type = player_data.action_type
	action_damage = player_data.action_damage
	passive_type = player_data.passive_type
	can_fly = player_data.can_fly
	state_types = player_data.state_types
	items_ids = player_data.items_ids
	texture = player_data.texture


func add_item(new_item_id: Util.ItemType) -> void:
	assert(items_ids[0] == Util.ItemType.NONE or items_ids[1] == Util.ItemType.NONE, 'No space to add item to player')
	if items_ids[0] == Util.ItemType.NONE:
		items_ids[0] = new_item_id
	elif items_ids[1] == Util.ItemType.NONE:
		items_ids[1] = new_item_id
