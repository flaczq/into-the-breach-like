extends Node

class_name SaveObject

var _id: int										= -1
var _description: String							= '-'
var _created: String								= '-'
var _updated: String								= '-'
var _unlocked_epoch_ids: Array[Util.EpochType]		= []
var _selected_epoch: Util.EpochType					= Util.EpochType.NONE
var _unlocked_player_ids: Array[Util.PlayerType]	= []
var _selected_player_ids: Array[Util.PlayerType]	= []
var _bought_item_ids: Dictionary					= {} # {item_id: player_id (-1: inventory)}
var _played_map_ids: Array[int]						= []
var _money: int	 									= -1
var _play_time: int									= -1
var _level_time: int 								= -1

var save_enabled: bool = false
var id: int:
	get: return _id
	set(value): apply_change('_id', value)
var description: String:
	get: return _description
	set(value): apply_change('_description', value)
var created: String:
	get: return _created
	set(value): apply_change('_created', value)
var updated: String:
	get: return _updated
	set(value): apply_change('_updated', value)
var unlocked_epoch_ids: Array[Util.EpochType]:
	get: return _unlocked_epoch_ids
	set(value): apply_change('_unlocked_epoch_ids', value)
var selected_epoch: Util.EpochType:
	get: return _selected_epoch
	set(value): apply_change('_selected_epoch', value)
var unlocked_player_ids: Array[Util.PlayerType]:
	get: return _unlocked_player_ids
	set(value): apply_change('_unlocked_player_ids', value)
var selected_player_ids: Array[Util.PlayerType]:
	get: return _selected_player_ids
	set(value): apply_change('_selected_player_ids', value)
var bought_item_ids: Dictionary:
	get: return _bought_item_ids
	set(value): apply_change('_bought_item_ids', value)
var played_map_ids: Array[int]:
	get: return _played_map_ids
	set(value): apply_change('_played_map_ids', value)
var money: int:
	get: return _money
	set(value): apply_change('_money', value)
var play_time: int:
	get: return _play_time
	set(value): apply_change('_play_time', value)
var level_time: int:
	get: return _level_time
	set(value): apply_change('_level_time', value)


func apply_change(field_name: String, value: Variant) -> void:
	self.set(field_name, value)
	if save_enabled:
		Config.save_save()


func init(new_id: int, is_tutorial: bool = false) -> void:
	id = new_id
	unlocked_epoch_ids.append(Util.EpochType.PREHISTORIC)
	# tutorial player is obviously unlocked but not added here to not show it in the selection screen
	unlocked_player_ids = [
		Util.PlayerType.PLAYER_1,
		Util.PlayerType.PLAYER_2,
		Util.PlayerType.PLAYER_3
	]
	money = 0
	play_time = 0
	
	if is_tutorial:
		selected_player_ids.push_back(Util.PlayerType.PLAYER_TUTORIAL)
