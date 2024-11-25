extends Node

enum Language {EN, PL}
enum BuildMode {RELEASE, DEBUG}
enum EngineMode {MENU, GAME, EDITOR}

var language: Language = Language.EN
var build_mode: BuildMode = BuildMode.RELEASE
var engine_mode: EngineMode = EngineMode.MENU
var editor: bool = false
var tutorial: bool = true
var antialiasing: bool = true
var default_speed: float = 0.3
var speed: float = 1.0

var score: int = 0
var loot_size: int = 0
var available_players: Array[PlayerObject] = []
var selected_players_scenes: Array[int] = []
var played_maps_indices: Array[int] = []


func _ready() -> void:
	add_to_group('NEVER_FREE')


func init_available_players(player: Node3D) -> void:
	var player_object: PlayerObject = PlayerObject.new()
	var player_data = player.get_data()
	player_object.init_from_player_data(player_data)
	available_players.push_back(player_object)
