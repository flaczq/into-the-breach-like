extends Node

enum Language {EN, PL}
enum BuildMode {RELEASE, DEBUG}
enum EngineMode {MENU, GAME, EDITOR}
enum PlayerType {FIRST, SECOND, THIRD, DEFAULT = -1}

var language: Language = Language.EN
var build_mode: BuildMode = BuildMode.DEBUG
var engine_mode: EngineMode = EngineMode.MENU
var tutorial: bool = true
var antialiasing: bool = true

# FIXME maybe somewhere else..?
var current_player_types: Array[PlayerType] = []


func _ready():
	add_to_group('NEVER_QUEUED')
