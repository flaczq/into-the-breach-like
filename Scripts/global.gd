extends Node

var language: Util.Language 				= Util.Language.EN				# CHANGEABLE
var camera_position: Util.CameraPosition	= Util.CameraPosition.MIDDLE	# CHANGEABLE
var build_mode: Util.BuildMode 				= Util.BuildMode.DEBUG
var engine_mode: Util.EngineMode 			= Util.EngineMode.MENU
var editor: bool 							= false
var tutorial: bool 							= true
var antialiasing: bool 						= true							# CHANGEABLE
var end_turn_confirmation: bool 			= true							# CHANGEABLE
var character_speed: float					= 0.3
var game_speed: float 						= 1.0							# CHANGEABLE
var volume: float 							= 0.8							# CHANGEABLE

var selected_players: Array[Player]		= []
var selected_items: Array[ItemObject]	= []
var money: int	 						= 0
var level_time: int 					= 0
var played_maps_ids: Array[int] 		= []


func _ready() -> void:
	add_to_group('NEVER_FREE')
