extends Node

var language: Util.Language = Util.Language.EN
var camera_position: Util.CameraPosition = Util.CameraPosition.MIDDLE
var build_mode: Util.BuildMode = Util.BuildMode.DEBUG
var engine_mode: Util.EngineMode = Util.EngineMode.MENU
var editor: bool = false
var tutorial: bool = true
var antialiasing: bool = true
var move_speed: float = 0.3
var default_speed: float = 1.2

var money: int = 0
var all_items: Array[ItemObject] = []
var selected_items: Array[ItemObject] = []
var all_players: Array[PlayerObject] = []
var selected_players: Array[PlayerObject] = []
var played_maps_ids: Array[int] = []


func _ready() -> void:
	add_to_group('NEVER_FREE')
