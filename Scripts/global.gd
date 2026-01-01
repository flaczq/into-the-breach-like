extends Node

var build_mode: Util.BuildMode		= Util.BuildMode.DEBUG
var engine_mode: Util.EngineMode	= Util.EngineMode.MENU
var editor: bool 					= false
var tutorial: bool 					= false
var character_speed: float			= 0.3
var settings: SettingsObject		= SettingsObject.new()
var saves: Array[SaveObject]		= [SaveObject.new(), SaveObject.new(), SaveObject.new(), SaveObject.new()]


func _ready() -> void:
	add_to_group('NEVER_FREE')
