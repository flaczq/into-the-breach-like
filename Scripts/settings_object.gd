extends Node

class_name SettingsObject

var language: Util.Language 				= Util.Language.EN
var camera_position: Util.CameraPosition	= Util.CameraPosition.MIDDLE
var antialiasing: bool 						= true
var end_turn_confirmation: bool 			= true
var game_speed: float 						= 1.0
var volume: float 							= 0.8
var difficulty: Util.DifficultyLevel		= Util.DifficultyLevel.EASY


func init() -> void:
	pass
