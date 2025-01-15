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


func init_from_item_object(item_object: ItemObject) -> void:
	id = item_object.id
	item_name = item_object.item_name
	cost = item_object.cost
	available = item_object.available
	texture = item_object.texture


func apply_to_player(target_player: Player, is_applied: bool = true) -> void:
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
		_: pass


func apply_to_player_object(target_player_object: PlayerObject, is_applied: bool = true) -> void:
	match id:
		Util.ItemType.HEALTH:
			if is_applied:
				target_player_object.max_health += 1
			else:
				target_player_object.max_health -= 1
		Util.ItemType.DAMAGE:
			if is_applied:
				target_player_object.damage += 1
			else:
				target_player_object.damage -= 1
		Util.ItemType.SHIELD:
			if is_applied:
				target_player_object.state_types.push_back(Util.StateType.GAVE_SHIELD)
			else:
				target_player_object.state_types.erase(Util.StateType.GAVE_SHIELD)
		Util.ItemType.MOVE_DISTANCE:
			if is_applied:
				target_player_object.move_distance += 1
			else:
				target_player_object.move_distance -= 1
		Util.ItemType.FLYING:
			if is_applied:
				target_player_object.can_fly = true
			else:
				target_player_object.can_fly = false
		_: pass
