extends Node

# TODO make serializable or w/e it takes to make it saveable
class_name SaveObject

var id: int										= -1
var description: String							= ''
var created: String								= ''
var updated: String								= ''
var unlocked_epoch_ids: Array[Util.EpochType]	= []
var selected_epoch: Util.EpochType				= Util.EpochType.NONE
var unlocked_player_ids: Array[Util.PlayerType]	= []
var selected_player_ids: Array[Util.PlayerType]	= []
var bought_item_ids: Dictionary					= {} # {item_id: player_id (-1: inventory)}
var played_map_ids: Array[int]					= []
var money: int	 								= -1
var play_time: int								= -1
var level_time: int 							= -1


func init(is_tutorial: bool = false) -> void:
	id = randi_range(10, 100)
	unlocked_epoch_ids.append(Util.EpochType.PREHISTORIC)
	# tutorial player is obviously unlocked but not added here to not show it in the selection screen
	unlocked_player_ids = [
		Util.PlayerType.PLAYER_1,
		Util.PlayerType.PLAYER_2,
		Util.PlayerType.PLAYER_3
	]
	money = 0
	
	if is_tutorial:
		selected_player_ids.push_back(Util.PlayerType.PLAYER_TUTORIAL)
