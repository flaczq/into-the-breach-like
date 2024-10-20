extends Node

enum Language {EN, PL}
enum BuildMode {RELEASE, DEBUG}
enum EngineMode {MENU, GAME, EDITOR}

var language: Language = Language.EN
var build_mode: BuildMode = BuildMode.DEBUG
var engine_mode: EngineMode = EngineMode.MENU
var tutorial: bool = true
var antialiasing: bool = true

var current_player_scenes: Array[int] = []


func _ready():
	add_to_group('NEVER_QUEUED')
