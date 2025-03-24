extends Node

class_name CivilianObject

var id: Util.CivilianType
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


func init_from_civilian_data(civilian_data: Dictionary) -> void:
	# id = scene, because scene: 0 is tutorial civilian
	id = civilian_data.id
	model_name = civilian_data.model_name
	max_health = civilian_data.max_health
	damage = civilian_data.damage
	move_distance = civilian_data.move_distance
	action_1_id = civilian_data.action_1_id
	#action_1 = civilian_data.action_1
	action_direction = civilian_data.action_direction
	passive_type = civilian_data.passive_type
	can_fly = civilian_data.can_fly
	# have to duplicate() to make them unique
	state_types = civilian_data.state_types.duplicate()
	textures = civilian_data.textures.duplicate()


#func init_from_civilian_object(civilian_object: CivilianObject) -> void:
	#id = civilian_object.id
	#model_name = civilian_object.model_name
	#max_health = civilian_object.max_health
	#damage = civilian_object.damage
	#move_distance = civilian_object.move_distance
	#action_1_id = civilian_object.action_1_id
	#action_1 = civilian_object.action_1
	#action_direction = civilian_object.action_direction
	#passive_type = civilian_object.passive_type
	#can_fly = civilian_object.can_fly
	## have to duplicate() to make them unique
	#state_types = civilian_object.state_types.duplicate()
	#textures = civilian_object.textures.duplicate()
