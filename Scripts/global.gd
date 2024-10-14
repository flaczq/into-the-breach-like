extends Node

enum Language {EN, PL}
enum EngineMode {MENU, GAME, EDITOR}

var language: Language = Language.EN
var engine_mode: EngineMode = EngineMode.MENU
var tutorial: bool = true
var antialiasing: bool = true


func _ready():
	add_to_group('NEVER_QUEUED')
