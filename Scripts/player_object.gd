extends Node

class_name PlayerObject

var id: Util.PlayerType
var model_name: String
var max_health: int
var damage: int
var move_distance: int
var action_1_id: Util.ActionType
var action_1: ActionObject
var action_2_id: Util.ActionType
var action_2: ActionObject
var action_direction: Util.ActionDirection
var passive_type: Util.PassiveType
var can_fly: bool
var state_types: Array[Util.StateType]
# TODO FIXME zamienić na ItemObject tak jak ActionObject
var items_ids: Array[Util.ItemType]
var textures: Array[CompressedTexture2D]
var items_applied: Array[bool]


func init_from_player_data(player_data: Dictionary) -> void:
	# id = scene, because scene: 0 is tutorial player
	id = player_data.id
	# TODO custom name
	model_name = player_data.model_name
	max_health = player_data.max_health
	damage = player_data.damage
	move_distance = player_data.move_distance
	action_1_id = player_data.action_1_id
	#action_1 = player_data.action_1
	action_2_id = player_data.action_2_id
	#action_2 = player_data.action_2
	action_direction = player_data.action_direction
	passive_type = player_data.passive_type
	can_fly = player_data.can_fly
	# have to duplicate() to make them unique
	state_types = player_data.state_types.duplicate()
	items_ids = player_data.items_ids.duplicate()
	textures = player_data.textures.duplicate()
	items_applied = player_data.items_applied.duplicate()


func init_from_player_object(player_object: PlayerObject) -> void:
	id = player_object.id
	model_name = player_object.model_name
	max_health = player_object.max_health
	damage = player_object.damage
	move_distance = player_object.move_distance
	action_1 = player_object.action_1
	action_2 = player_object.action_2
	action_direction = player_object.action_direction
	passive_type = player_object.passive_type
	can_fly = player_object.can_fly
	# have to duplicate() to make them unique
	state_types = player_object.state_types.duplicate()
	items_ids = player_object.items_ids.duplicate()
	textures = player_object.textures.duplicate()
	items_applied = player_object.items_applied.duplicate()


func set_items(new_items_ids: Array[Util.ItemType]) -> void:
	assert(new_items_ids.size() == 2, 'Wrong new items ids size')
	items_ids[0] = new_items_ids[0]
	items_ids[1] = new_items_ids[1]


func set_item(new_item_id: Util.ItemType, target_player_item_index: int = -1) -> void:
	var item_index = (target_player_item_index) if (target_player_item_index >= 0) else (items_ids.find(Util.ItemType.NONE))
	assert(items_ids[item_index] == Util.ItemType.NONE, 'No space to add item to player')
	items_ids[item_index] = new_item_id


func unset_item(item_id: Util.ItemType) -> void:
	var item_index = items_ids.find(item_id)
	assert(item_index >= 0, 'No item in player to remove')
	items_ids[item_index] = Util.ItemType.NONE


func move_item_to_empty(item_id: Util.ItemType, target_player_item_index: int) -> void:
	# switching items not available
	assert(items_ids[target_player_item_index] == Util.ItemType.NONE, 'No space to move item inside player')
	var item_index = items_ids.find(item_id)
	items_ids[item_index] = Util.ItemType.NONE
	items_ids[target_player_item_index] = item_id
