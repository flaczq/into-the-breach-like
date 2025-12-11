extends Node

var settings_cfg = ConfigFile.new()
var save_cfg = ConfigFile.new()

const SETTINGS_FILEPATH: String = 'user://settings.cfg'
const SAVE_FILEPATHS: Array[String] = [
	'user://save_abc.cfg',
	'user://save_def.cfg',
	'user://save_ghi.cfg'
]


func _ready() -> void:
	add_to_group('NEVER_FREE')
	
	load_settings()
	load_saves()


func load_settings() -> void:
	var load_result = settings_cfg.load(SETTINGS_FILEPATH)
	if load_result != OK:
		save_settings()
		print('Virgin settings file in ' + SETTINGS_FILEPATH + ' created!')
	else:
		# settings file exists
		var current_language = settings_cfg.get_value('game', 'volume', Global.settings.volume)
		var current_camera_position = settings_cfg.get_value('game', 'camera_position', Global.settings.camera_position)
		var current_antialiasing = settings_cfg.get_value('game', 'antialiasing', Global.settings.antialiasing)
		var current_end_turn_confirmation = settings_cfg.get_value('game', 'end_turn_confirmation', Global.settings.end_turn_confirmation)
		var current_game_speed = settings_cfg.get_value('game', 'game_speed', Global.settings.game_speed)
		var current_volume = settings_cfg.get_value('game', 'volume', Global.settings.volume)
		var current_difficulty = settings_cfg.get_value('game', 'difficulty', Global.settings.difficulty)
		var current_selected_save_index = settings_cfg.get_value('other', 'selected_save_index', Global.settings.selected_save_index)
		
		Global.settings.language = current_language
		Global.settings.camera_position = current_camera_position
		Global.settings.antialiasing = current_antialiasing
		Global.settings.end_turn_confirmation = current_end_turn_confirmation
		Global.settings.game_speed = current_game_speed
		Global.settings.volume = current_volume
		Global.settings.difficulty = current_difficulty
		Global.settings.selected_save_index = current_selected_save_index
		Global.settings.save_enabled = true
	
	var current_project_version = ProjectSettings.get_setting('application/config/version')
	if current_project_version != settings_cfg.get_value('engine', 'version', 'XXX'):
		print('Different settings version! Maybe do something..?')


func save_settings() -> void:
	print('settings saved')
	settings_cfg.clear()
	
	settings_cfg.set_value('engine', 'version', ProjectSettings.get_setting('application/config/version'))
	settings_cfg.set_value('engine', 'name', ProjectSettings.get_setting('application/config/name'))
	
	settings_cfg.set_value('game', 'language', Global.settings.language)
	settings_cfg.set_value('game', 'camera_position', Global.settings.camera_position)
	settings_cfg.set_value('game', 'antialiasing', Global.settings.antialiasing)
	settings_cfg.set_value('game', 'end_turn_confirmation', Global.settings.end_turn_confirmation)
	settings_cfg.set_value('game', 'game_speed', Global.settings.game_speed)
	settings_cfg.set_value('game', 'volume', Global.settings.volume)
	settings_cfg.set_value('game', 'difficulty', Global.settings.difficulty)
	
	settings_cfg.set_value('other', 'selected_save_index', Global.settings.selected_save_index)
	
	settings_cfg.save(SETTINGS_FILEPATH)


func load_saves() -> void:
	var i = 0
	for save_filepath in SAVE_FILEPATHS:
		load_save(i, save_filepath)
		i += 1


func load_save(i: int, save_filepath: String) -> void:
	var load_result = save_cfg.load(save_filepath)
	if load_result != OK:
		save_save(i)
		print('Virgin save file in ' + save_filepath + ' created!')
	else:
		# save file exists
		var current_id = save_cfg.get_value('state', 'id', Global.saves[i].id)
		var current_description = save_cfg.get_value('state', 'description', Global.saves[i].description)
		var current_created = save_cfg.get_value('state', 'created', Global.saves[i].created)
		var current_updated = save_cfg.get_value('state', 'updated', Global.saves[i].updated)
		var current_unlocked_epoch_ids = save_cfg.get_value('state', 'unlocked_epoch_ids', Global.saves[i].unlocked_epoch_ids)
		var current_selected_epoch = save_cfg.get_value('state', 'selected_epoch', Global.saves[i].selected_epoch)
		var current_unlocked_player_ids = save_cfg.get_value('state', 'unlocked_player_ids', Global.saves[i].unlocked_player_ids)
		var current_selected_player_ids = save_cfg.get_value('state', 'selected_player_ids', Global.saves[i].selected_player_ids)
		var current_bought_item_ids = save_cfg.get_value('state', 'bought_item_ids', Global.saves[i].bought_item_ids)
		var current_played_map_ids = save_cfg.get_value('state', 'played_map_ids', Global.saves[i].played_map_ids)
		var current_money = save_cfg.get_value('state', 'money', Global.saves[i].money)
		var current_play_time = save_cfg.get_value('state', 'play_time', Global.saves[i].play_time)
		var current_level_time = save_cfg.get_value('state', 'level_time', Global.saves[i].level_time)
		
		Global.saves[i].id = current_id
		Global.saves[i].description = current_description
		Global.saves[i].created = current_created
		Global.saves[i].updated = current_updated
		Global.saves[i].unlocked_epoch_ids = current_unlocked_epoch_ids
		Global.saves[i].selected_epoch = current_selected_epoch
		Global.saves[i].unlocked_player_ids = current_unlocked_player_ids
		Global.saves[i].selected_player_ids = current_selected_player_ids
		Global.saves[i].bought_item_ids = current_bought_item_ids
		Global.saves[i].played_map_ids = current_played_map_ids
		Global.saves[i].money = current_money
		Global.saves[i].play_time = current_play_time
		Global.saves[i].level_time = current_level_time
	
	var current_project_version = ProjectSettings.get_setting('application/config/version')
	if current_project_version != save_cfg.get_value('engine', 'version', 'XXX'):
		print('Different settings version! Maybe do something..?')


func save_save(i: int = Global.settings.selected_save_index) -> void:
	assert(i >= 0, 'Saving save with wrong index')
	print('save saved')
	save_cfg.clear()
	
	save_cfg.set_value('engine', 'version', ProjectSettings.get_setting('application/config/version'))
	save_cfg.set_value('engine', 'name', ProjectSettings.get_setting('application/config/name'))
	
	save_cfg.set_value('state', 'id', Global.saves[i].id)
	save_cfg.set_value('state', 'description', Global.saves[i].description)
	save_cfg.set_value('state', 'created', Global.saves[i].created)
	save_cfg.set_value('state', 'updated', Global.saves[i].updated)
	save_cfg.set_value('state', 'unlocked_epoch_ids', Global.saves[i].unlocked_epoch_ids)
	save_cfg.set_value('state', 'selected_epoch', Global.saves[i].selected_epoch)
	save_cfg.set_value('state', 'unlocked_player_ids', Global.saves[i].unlocked_player_ids)
	save_cfg.set_value('state', 'selected_player_ids', Global.saves[i].selected_player_ids)
	save_cfg.set_value('state', 'bought_item_ids', Global.saves[i].bought_item_ids)
	save_cfg.set_value('state', 'played_map_ids', Global.saves[i].played_map_ids)
	save_cfg.set_value('state', 'money', Global.saves[i].money)
	save_cfg.set_value('state', 'play_time', Global.saves[i].play_time)
	save_cfg.set_value('state', 'level_time', Global.saves[i].level_time)
	
	save_cfg.save(SAVE_FILEPATHS[i])
