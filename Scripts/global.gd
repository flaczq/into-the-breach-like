extends Node

enum Language {EN, PL}
enum EngineMode {MENU, GAME, EDITOR}
enum PlayerType {FIRST, SECOND, THIRD, DEFAULT = -1}

var language: Language = Language.EN
var engine_mode: EngineMode = EngineMode.MENU
var tutorial: bool = true
var antialiasing: bool = true

# FIXME maybe somewhere else..?
var current_player_types: Array[PlayerType] = []


func _ready():
	add_to_group('NEVER_QUEUED')
