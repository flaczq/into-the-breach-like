extends Util

class_name PlayerObject

var id: int
var model_name: String
var max_health: int
var damage: int
var damage_upgraded: int
# TODO more upgrades than 1
var is_damage_upgraded: bool
var move_distance: int
var action_min_distance: int
var action_max_distance: int
var action_direction: ActionDirection
var action_type: ActionType
var action_damage: int
var passive_type: PassiveType
var can_fly: bool
var state_types: Array[StateType]


func init_from_player_data(player_data: Dictionary) -> void:
	# id = scene, because scene: 0 is tutorial player
	id = player_data.id
	# TODO custom name
	model_name = player_data.model_name
	max_health = player_data.max_health
	damage = player_data.damage
	damage_upgraded = player_data.damage_upgraded
	is_damage_upgraded = false
	move_distance = player_data.move_distance
	action_min_distance = player_data.action_min_distance
	action_max_distance = player_data.action_max_distance
	action_direction = player_data.action_direction
	action_type = player_data.action_type
	action_damage = player_data.action_damage
	passive_type = player_data.passive_type
	can_fly = player_data.can_fly
	state_types = player_data.state_types
