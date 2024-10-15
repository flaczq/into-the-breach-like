extends Util

const SAVED_LEVELS_FILE_PATH: String = 'res://Data/saved_levels.txt'
const PLAYERS_DATA = [
	{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 7},
	{'scene': 1, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 7},
	{'scene': 2, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 7},
]
const ENEMIES_DATA = [
	{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 7},
	{'scene': 1, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 7},
	{'scene': 2, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 7},
]
const CIVILIANS_DATA = [
	{'scene': 0, 'health': 2, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
	{'scene': 1, 'health': 2, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
	{'scene': 2, 'health': 2, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
]


func generate_data(level_type, level):
	var file = FileAccess.open(SAVED_LEVELS_FILE_PATH, FileAccess.READ)
	var current_level = calculate_level_for_level_type(level_type, level)
	var content = file.get_as_text()
	var level_data_string = content.get_slice(current_level + '->START', 1).get_slice(current_level + '->STOP', 0)#.strip_escapes()
	var level_data = parse_data(level_data_string)
	
	add_characters_data(level_data)
	
	return level_data


func parse_data(level_data_string):
	var json = JSON.new()
	var parse_status = json.parse(level_data_string)
	assert(parse_status == OK, json.get_error_message() + ' in ' + level_data_string.split('\n')[json.get_error_line()])
	return json.data


func calculate_level_for_level_type(level_type, level):
	var current_level
	
	if level_type == LevelType.TUTORIAL:
		current_level = level
	else:
		# FIXME
		current_level = randi_range(1, 2)
	
	return str(current_level)


func add_characters_data(level_data):
	# FIXME hardcoded
	level_data.players = [PLAYERS_DATA[0]]
	level_data.enemies = [ENEMIES_DATA[0]]
	level_data.civilians = [CIVILIANS_DATA[0]]
