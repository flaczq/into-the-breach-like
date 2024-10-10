extends Util

const KILL_ENEMIES_LEVELS_FILE_PATH: String = 'res://Data/kill_enemies_levels.txt'
const TUTORIAL_LEVELS_DATA = [
	{
		# 4x4
		'config': {'level': '1', 'level_type': LevelType.TUTORIAL, 'tiles': 'GGGGPPPPPPPPMMMM', 'tiles_assets': 'TTTTS0000000MMMM', 'max_turns': 5},
		'map': {'scene': 0, 'spawn_player_coords': [Vector2i(2, 2), Vector2i(3, 2)], 'spawn_enemy_coords': [Vector2i(2, 4), Vector2i(3, 4)], 'spawn_civilian_coords': []},
		'players': [
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 3},
		],
		'enemies': [
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 3},
		],
		'civilians': [],
	},
	{
		'config': {'level': '2', 'level_type': LevelType.TUTORIAL, 'tiles': 'PPGPPPGPPPGPMMMM', 'tiles_assets': '0000S00000000000', 'max_turns': 5},
		'map': {'scene': 0, 'spawn_player_coords': [Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 1), Vector2i(2, 2), Vector2i(3, 1), Vector2i(3, 2)], 'spawn_enemy_coords': [Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4)], 'spawn_civilian_coords': []},
		'players': [
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 3},
		],
		'enemies': [
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.NONE, 'action_distance': 3},
		],
		'civilians': [],
	},
	{
		# 6x6
		'config': {'level': '3', 'level_type': LevelType.TUTORIAL, 'tiles': 'GGGGPPGGGGPPPPPPPPPPPPPMPPPPPMPPPPPM', 'tiles_assets': '00000S000000000000000000000000000000', 'max_turns': 5},
		'map': {'scene': 1, 'spawn_player_coords': [], 'spawn_enemy_coords': [], 'spawn_civilian_coords': []},
		'players': [
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.PUSH_BACK, 'action_distance': 5},
		],
		'enemies': [
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 5},
		],
		'civilians': [
			{'scene': 0, 'health': 2, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
		],
	},
	{
		'config': {'level': '4', 'level_type': LevelType.TUTORIAL, 'tiles': 'GGGGPPGGGGPPPPPPPPPPPPPMPPPPPMPPPPPM', 'tiles_assets': '00000S000000000000000000000000000000', 'max_turns': 5},
		'map': {'scene': 1, 'spawn_player_coords': [], 'spawn_enemy_coords': [], 'spawn_civilian_coords': []},
		'players': [
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.NONE, 'action_distance': 5},
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.PUSH_BACK, 'action_distance': 5},
		],
		'enemies': [
			{'scene': 0, 'health': 2, 'damage': 2, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 5},
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.PULL_FRONT, 'action_distance': 5},
		],
		'civilians': [
			{'scene': 0, 'health': 2, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
		],
	},
	{
		# 8x8
		'config': {'level': '5', 'level_type': LevelType.TUTORIAL, 'tiles': 'GPPPPGGGPGPPPPGGPPGPPPPGPPPGPPPPPPPPGPPPPPPPPGPPPPPPPPGPMMMMPPPG', 'tiles_assets': '0000000000000000000000000000000000000000000000000000000000000000', 'max_turns': 5},
		'map': {'scene': 2, 'spawn_player_coords': [], 'spawn_enemy_coords': [], 'spawn_civilian_coords': []},
		'players': [
			{'scene': 0, 'health': 2, 'damage': 2, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 7},
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.PUSH_BACK, 'action_distance': 7},
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.PULL_FRONT, 'action_distance': 7},
		],
		'enemies': [
			{'scene': 0, 'health': 2, 'damage': 2, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 7},
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.PUSH_BACK, 'action_distance': 7},
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.PULL_FRONT, 'action_distance': 7},
		],
		'civilians': [
			{'scene': 0, 'health': 2, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
			{'scene': 0, 'health': 2, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
		],
	},
	{
		'config': {'level': '6', 'level_type': LevelType.TUTORIAL, 'tiles': 'PPPMGGGGPPPMPGGGPPPMPPGGPPPMPPGGPMMMMMMPPPPMPPPPPPPMPPPPPMMPMMPP', 'tiles_assets': '0000000000000000000000000000000000000000000000000000000000000000', 'max_turns': 5},
		'map': {'scene': 2, 'spawn_player_coords': [], 'spawn_enemy_coords': [], 'spawn_civilian_coords': []},
		'players': [
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.PUSH_BACK, 'action_distance': 7},
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_DOT, 'action_type': ActionType.GIVE_SHIELD, 'action_distance': 7},
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.PULL_FRONT, 'action_distance': 7},
		],
		'enemies': [
			{'scene': 0, 'health': 2, 'damage': 2, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 7},
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_LINE, 'action_type': ActionType.PUSH_BACK, 'action_distance': 7},
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.PULL_FRONT, 'action_distance': 7},
		],
		'civilians': [
			{'scene': 0, 'health': 2, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
			{'scene': 0, 'health': 2, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
			{'scene': 0, 'health': 2, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
		],
	}
]


func generate_data(level_type, level):
	if level_type == LevelType.TUTORIAL:
		return TUTORIAL_LEVELS_DATA[level - 1]
	
	var file_path = get_level_file_path(level_type)
	var file = FileAccess.open(file_path, FileAccess.READ)
	var current_level = calculate_level_for_level_type(level_type, level)
	var content = file.get_as_text()
	var tiles = content.get_slice(current_level + '>TILES_START', 1).get_slice(current_level + '>TILES_STOP', 0).strip_escapes()
	var tiles_assets = content.get_slice(current_level + '->ASSETS_START', 1).get_slice(current_level + '->ASSETS_STOP', 0).strip_escapes()
	
	# TODO
	var temp = TUTORIAL_LEVELS_DATA[5].duplicate()
	var temp_config = temp.config.duplicate()
	temp_config.tiles = tiles
	temp_config.tiles_assets = tiles_assets
	temp.config = temp_config
	return temp


func get_level_file_path(level_type):
	match level_type:
		#LevelType.TUTORIAL: return TUTORIAL_LEVELS_FILE_PATH
		LevelType.KILL_ENEMIES: return KILL_ENEMIES_LEVELS_FILE_PATH
		_:
			print('unknown level type: ' + level_type)
			return KILL_ENEMIES_LEVELS_FILE_PATH


func calculate_level_for_level_type(level_type, level):
	var current_level
	
	if level_type == LevelType.TUTORIAL:
		current_level = level
	else:
		# FIXME
		current_level = randi_range(1, 2)
	
	return str(current_level)
