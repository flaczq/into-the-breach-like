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


func apply_to_player(target_player: Player) -> void:
	match id:
		Util.ItemType.HEALTH:
			target_player.max_health += 1
			target_player.health += 1
		Util.ItemType.DAMAGE:
			target_player.damage += 1
		Util.ItemType.SHIELD:
			target_player.state_types.push_back(Util.StateType.GAVE_SHIELD)
		Util.ItemType.MOVE_DISTANCE:
			target_player.move_distance += 1
		Util.ItemType.FLYING:
			target_player.can_fly = true
		_: pass
