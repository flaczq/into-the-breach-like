extends Util

const SAVED_LEVELS_FILE_PATH: String = 'res://Data/saved_levels.txt'
const TUTORIAL_LEVELS_FILE_PATH: String = 'res://Data/tutorial_levels.txt'


func generate_data(level_type, level):
	var levels_file_path = get_levels_file_path(level_type)
	var file = FileAccess.open(levels_file_path, FileAccess.READ)
	var content = file.get_as_text()
	var level_data_string = content.get_slice(str(level) + '->START', 1).get_slice(str(level) + '->STOP', 0)#.strip_escapes()
	assert(level_data_string != content, 'Add level ' + str(level) + ' to levels file: ' + str(levels_file_path))
	var level_data = parse_data(level_data_string)
	
	add_characters(level_data)
	
	return level_data


func parse_data(level_data_string):
	var json = JSON.new()
	var parse_status = json.parse(level_data_string)
	assert(parse_status == OK, json.get_error_message() + ' in ' + level_data_string.split('\n')[json.get_error_line()])
	return json.data


func get_levels_file_path(level_type):
	if level_type == LevelType.TUTORIAL:
		return TUTORIAL_LEVELS_FILE_PATH
	
	return SAVED_LEVELS_FILE_PATH


func add_characters(level_data):
	level_data.player_scenes = []
	level_data.enemy_scenes = []
	level_data.civilian_scenes = []
	
	if level_data.level_type == LevelType.TUTORIAL:
		# TODO FIXME hardcoded
		if level_data.level == 1:
			level_data.player_scenes.push_back(0)
			level_data.enemy_scenes.push_back(0)
			#level_data.civilian_scenes = []
		elif level_data.level == 2:
			level_data.player_scenes.push_back(0)
			level_data.enemy_scenes.push_back(0)
	else:
		# TODO pick enemies and civilians by random(?) based on level type and level number
		for current_player_scene in Global.current_player_scenes:
			level_data.player_scenes.push_back(current_player_scene)
		
		# 0 scene is always tutorial
		level_data.enemy_scenes.push_back(randi_range(1, 2))
		level_data.civilian_scenes.push_back(randi_range(1, 1))
