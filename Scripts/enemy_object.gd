extends Node

class_name EnemyObject

var id: Util.EnemyType
var model_name: String
var max_health: int
var damage: int
var move_distance: int
var action_1_id: Util.ActionType
var action_1: ActionObject
var action_direction: Util.ActionDirection
var passive_type: Util.PassiveType
var can_fly: bool
var state_types: Array[Util.StateType]
var textures: Array[CompressedTexture2D]
var arrow_color: Color
var arrow_highlighted_color: Color


func init_from_enemy_data(enemy_data: Dictionary) -> void:
	# id = scene, because scene: 0 is tutorial enemy
	id = enemy_data.id
	model_name = enemy_data.model_name
	max_health = enemy_data.max_health
	damage = enemy_data.damage
	move_distance = enemy_data.move_distance
	action_1_id = enemy_data.action_1_id
	#action_1 = enemy_data.action_1
	action_direction = enemy_data.action_direction
	passive_type = enemy_data.passive_type
	can_fly = enemy_data.can_fly
	# have to duplicate() to make them unique
	state_types = enemy_data.state_types.duplicate()
	textures = enemy_data.textures.duplicate()
	arrow_color = enemy_data.arrow_color
	arrow_highlighted_color = enemy_data.arrow_highlighted_color


#func init_from_enemy_object(enemy_object: EnemyObject) -> void:
	#id = enemy_object.id
	#model_name = enemy_object.model_name
	#max_health = enemy_object.max_health
	#damage = enemy_object.damage
	#move_distance = enemy_object.move_distance
	#action_1 = enemy_object.action_1
	#action_direction = enemy_object.action_direction
	#passive_type = enemy_object.passive_type
	#can_fly = enemy_object.can_fly
	## have to duplicate() to make them unique
	#state_types = enemy_object.state_types.duplicate()
	#textures = enemy_object.textures.duplicate()
	#arrow_color = enemy_object.arrow_color
	#arrow_highlighted_color = enemy_object.arrow_highlighted_color
