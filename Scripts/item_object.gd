extends Node

class_name ItemObject

var id: Util.ItemType
var item_name: String
var cost: int
var description: String
var is_available: bool
var is_applied: bool
var textures: Array[CompressedTexture2D]


func init_from_item_data(item_data: Dictionary) -> void:
	id = item_data.id
	item_name = item_data.item_name
	cost = item_data.cost
	description = item_data.description
	is_available = item_data.is_available
	is_applied = item_data.is_applied
	textures = item_data.textures


func init_from_item_object(item_object: ItemObject) -> void:
	id = item_object.id
	item_name = item_object.item_name
	cost = item_object.cost
	description = item_object.description
	is_available = item_object.is_available
	is_applied = item_object.is_applied
	textures = item_object.textures


func apply_to_player(target_player: Player) -> void:
	assert(not is_applied, 'Item already applied')
	match id:
		Util.ItemType.HEALTH:
			if is_applied:
				target_player.max_health += 1
				target_player.health += 1
			else:
				target_player.max_health -= 1
				target_player.health -= 1
		Util.ItemType.DAMAGE:
			if is_applied:
				target_player.damage += 1
			else:
				target_player.damage -= 1
		Util.ItemType.SHIELD:
			if is_applied:
				target_player.state_types.push_back(Util.StateType.GAVE_SHIELD)
			else:
				target_player.state_types.erase(Util.StateType.GAVE_SHIELD)
		Util.ItemType.MOVE_DISTANCE:
			if is_applied:
				target_player.move_distance += 1
			else:
				target_player.move_distance -= 1
		Util.ItemType.FLYING:
			if is_applied:
				target_player.can_fly = true
			else:
				target_player.can_fly = false
		Util.ItemType.SWIMMING:
			if is_applied:
				target_player.can_swim = true
			else:
				target_player.can_swim = false
		_: pass
	
	is_applied = true
