extends Node

var language: Util.Language = Util.Language.EN
var camera_position: Util.CameraPosition = Util.CameraPosition.MIDDLE
var build_mode: Util.BuildMode = Util.BuildMode.DEBUG
var engine_mode: Util.EngineMode = Util.EngineMode.MENU
var editor: bool = false
var tutorial: bool = true
var antialiasing: bool = true
var default_speed: float = 0.3
var speed: float = 1.0

var money: int = 0
var all_items: Array[ItemObject] = []
var selected_items_ids: Array[Util.ItemType] = []
var all_players: Array[PlayerObject] = []
var selected_players_ids: Array[Util.PlayerType] = []
var played_maps_ids: Array[int] = []


func _ready() -> void:
	add_to_group('NEVER_FREE')
