extends Node

var settings = ConfigFile.new()

const SETTINGS_FILE_PATH: String = 'user://settings.cfg'


func _ready() -> void:
	add_to_group('NEVER_FREE')
	
	load_settings()


func load_settings() -> void:
	var load_result = settings.load(SETTINGS_FILE_PATH)
	if load_result != OK:
		save_settings()
		print('Settings file created!')
	else:
		# settings file exists
		var current_language = settings.get_value('game', 'volume', Global.settings.volume)
		var current_camera_position = settings.get_value('game', 'camera_position', Global.settings.camera_position)
		var current_antialiasing = settings.get_value('game', 'antialiasing', Global.settings.antialiasing)
		var current_end_turn_confirmation = settings.get_value('game', 'end_turn_confirmation', Global.settings.end_turn_confirmation)
		var current_game_speed = settings.get_value('game', 'game_speed', Global.settings.game_speed)
		var current_volume = settings.get_value('game', 'volume', Global.settings.volume)
		var current_difficulty = settings.get_value('game', 'difficulty', Global.settings.difficulty)
		
		Global.settings.language = current_language
		Global.settings.camera_position = current_camera_position
		Global.settings.antialiasing = current_antialiasing
		Global.settings.end_turn_confirmation = current_end_turn_confirmation
		Global.settings.game_speed = current_game_speed
		Global.settings.volume = current_volume
		Global.settings.difficulty = current_difficulty
	
	var current_project_version = ProjectSettings.get_setting('application/config/version')
	if current_project_version != settings.get_value('engine', 'version'):
		print('Different settings version! Maybe do something..?')


func save_settings() -> void:
	settings.set_value('engine', 'version', ProjectSettings.get_setting('application/config/version'))
	settings.set_value('engine', 'name', ProjectSettings.get_setting('application/config/name'))
	
	settings.set_value('game', 'language', Global.settings.language)
	settings.set_value('game', 'camera_position', Global.settings.camera_position)
	settings.set_value('game', 'antialiasing', Global.settings.antialiasing)
	settings.set_value('game', 'end_turn_confirmation', Global.settings.end_turn_confirmation)
	settings.set_value('game', 'game_speed', Global.settings.game_speed)
	settings.set_value('game', 'volume', Global.settings.volume)
	settings.set_value('game', 'difficulty', Global.settings.difficulty)
	
	settings.save(SETTINGS_FILE_PATH)
