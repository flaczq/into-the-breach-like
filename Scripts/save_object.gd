extends Node

# TODO make serializable or w/e it takes to make it saveable
class_name SaveObject

var id: int										= 0
var description: String							= ''
var created_date: String						= Time.get_datetime_string_from_system()
var updated_date: String						= Time.get_datetime_string_from_system()
# tutorial player is obviously unlocked but not added here to not show it in the selection screen
var unlocked_player_ids: Array[int]				= [
	Util.PlayerType.PLAYER_1,
	Util.PlayerType.PLAYER_2,
	Util.PlayerType.PLAYER_3
]
#var selected_players: Array[Player]			= []
var selected_player_ids: Array[Util.PlayerType] = []
#var selected_items: Array[ItemObject]			= []
var bought_item_ids: Dictionary					= {}# {item_id: player_id (-1: inventory)}
var played_map_ids: Array[int]					= []
var money: int	 								= 0
var play_time: int								= 0
var level_time: int 							= 0
