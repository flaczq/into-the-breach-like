extends Node

enum Language {EN, PL}
enum BuildMode {RELEASE, DEBUG}
enum EngineMode {MENU, GAME, EDITOR}

var language: Language = Language.EN
var build_mode: BuildMode = BuildMode.DEBUG
var engine_mode: EngineMode = EngineMode.MENU
var editor: bool = false
var tutorial: bool = true
var antialiasing: bool = true
var default_speed: float = 0.3
var speed: float = 1.0

var score: int = 0
var players_scenes: Array[int] = []
var loot_count: int = 0


func _ready() -> void:
	add_to_group('NEVER_FREED')
