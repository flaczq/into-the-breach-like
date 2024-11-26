extends Node

enum Language {EN, PL}
enum CameraPosition {HIGH, MIDDLE, LOW}
enum BuildMode {RELEASE, DEBUG}
enum EngineMode {MENU, GAME, EDITOR}

var language: Language = Language.EN
var camera_position: CameraPosition = CameraPosition.MIDDLE
var build_mode: BuildMode = BuildMode.DEBUG
var engine_mode: EngineMode = EngineMode.MENU
var editor: bool = false
var tutorial: bool = true
var antialiasing: bool = true
var default_speed: float = 0.3
var speed: float = 1.0

var score: int = 0
var loot_size: int = 0
var available_players: Array[PlayerObject] = []
var selected_players: Array[PlayerObject] = []
var played_maps_indices: Array[int] = []


func _ready() -> void:
	add_to_group('NEVER_FREE')
