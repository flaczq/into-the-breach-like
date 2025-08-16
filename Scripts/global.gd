extends Node

var build_mode: Util.BuildMode 				= Util.BuildMode.DEBUG
var engine_mode: Util.EngineMode 			= Util.EngineMode.MENU
var editor: bool 							= false
var tutorial: bool 							= true
var character_speed: float					= 0.3
var settings: SettingsObject				= SettingsObject.new()
var save: SaveObject						= SaveObject.new()


func _ready() -> void:
	add_to_group('NEVER_FREE')
