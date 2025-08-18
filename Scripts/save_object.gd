extends Node

# TODO make serializable or w/e it takes to make it saveable
class_name SaveObject

var id: int								= 0
# no tutorial player to not add it on selection screen
var playable_player_ids: Array[int]		= [
	Util.PlayerType.PLAYER_1,
	Util.PlayerType.PLAYER_2,
	Util.PlayerType.PLAYER_3
]
# FIXME change this to IDs only, think through tho if this gonna work...
var selected_players: Array[Player]		= [] #var selected_player_ids: Array[Util.PlayerType]
var selected_items: Array[ItemObject]	= [] #var selected_item_ids: Dictionary <item_id: int, player_id: int>
var played_map_ids: Array[int]			= []
var money: int	 						= 0
var level_time: int 					= 0
