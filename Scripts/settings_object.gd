extends Node

class_name SettingsObject

var _language: Util.Language				= Util.Language.EN
var _camera_position: Util.CameraPosition	= Util.CameraPosition.MIDDLE
var _antialiasing: bool						 = true
var _end_turn_confirmation: bool			 = true
var _game_speed: float						 = 1.0
var _volume: float							 = 0.8
var _difficulty: Util.DifficultyLevel		 = Util.DifficultyLevel.EASY

var language: Util.Language:
	get: return _language
	set(value): apply_change('_language', value)
var camera_position: Util.CameraPosition:
	get: return _camera_position
	set(value): apply_change('_camera_position', value)
var antialiasing: bool:
	get: return _antialiasing
	set(value): apply_change('_antialiasing', value)
var end_turn_confirmation: bool:
	get: return _end_turn_confirmation
	set(value): apply_change('_end_turn_confirmation', value)
var game_speed: float:
	get: return _game_speed
	set(value): apply_change('_game_speed', value)
var volume: float:
	get: return _volume
	set(value): apply_change('_volume', value)
var difficulty: Util.DifficultyLevel:
	get: return _difficulty
	set(value): apply_change('_difficulty', value)


func apply_change(field_name: String, value: Variant) -> void:
	self.set(field_name, value)
	Config.save_settings()
