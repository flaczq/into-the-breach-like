extends Node

# TODO make serializable or w/e it takes to make it saveable
class_name SaveObject

# no tutorial player to not add it on selection screen
var playable_players_ids: Array[int]	= [
	Util.PlayerType.PLAYER_1,
	Util.PlayerType.PLAYER_2,
	Util.PlayerType.PLAYER_3
]
# FIXME change this to IDs only, think through tho if this gonna work...
var selected_players: Array[Player]		= []
var selected_items: Array[ItemObject]	= []
var played_maps_ids: Array[int] 		= []
var money: int	 						= 0
var level_time: int 					= 0
