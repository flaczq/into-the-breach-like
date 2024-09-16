extends Util

@export var map_scenes: Array[PackedScene] = []
@export var player_scenes: Array[PackedScene] = []
@export var enemy_scenes: Array[PackedScene] = []
@export var civilian_scenes: Array[PackedScene] = []

@onready var game_info = $"../CanvasLayer/UI/GameInfo"
@onready var tile_info = $"../CanvasLayer/UI/PlayerInfoContainer/TileInfo"
@onready var end_turn_button = $"../CanvasLayer/UI/PlayerInfoContainer/PlayerButtons/EndTurnButton"
@onready var shoot_button = $"../CanvasLayer/UI/PlayerInfoContainer/PlayerButtons/ShootButton"
@onready var action_button = $"../CanvasLayer/UI/PlayerInfoContainer/PlayerButtons/ActionButton"
@onready var level_end_popup = $"../CanvasLayer/UI/LevelEndPopup"
@onready var level_end_label = $"../CanvasLayer/UI/LevelEndPopup/LevelEndLabel"

const LEVELS_DATA: Array = [
	{
		# 4x4
		'map_scene': 0,
		'players': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE},
		],
		'enemies': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.NONE},
		],
		'civilians': [],
		'max_turns': 5
	},
	{
		'map_scene': 0,
		'players': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.PUSH_BACK},
		],
		'enemies': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE},
		],
		'civilians': [
			{'scene': 0, 'health': 3, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE},
		],
		'max_turns': 5
	},
	{
		# 6x6
		'map_scene': 1,
		'players': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.NONE},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.PULL_FRONT},
		],
		'enemies': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_LINE, 'action_type': ActionType.PUSH_BACK},
		],
		'civilians': [
			{'scene': 0, 'health': 3, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE},
		],
		'max_turns': 5
	},
	{
		'map_scene': 1,
		'players': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.NONE},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_LINE, 'action_type': ActionType.PUSH_BACK},
		],
		'enemies': [
			{'scene': 0, 'health': 3, 'damage': 2, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_DOT, 'action_type': ActionType.PULL_FRONT},
		],
		'civilians': [
			{'scene': 0, 'health': 3, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE},
		],
		'max_turns': 5
	},
	{
		# 8x8
		'map_scene': 2,
		'players': [
			{'scene': 0, 'health': 3, 'damage': 2, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.NONE},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.PUSH_BACK},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_LINE, 'action_type': ActionType.PULL_FRONT},
		],
		'enemies': [
			{'scene': 0, 'health': 4, 'damage': 2, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.NONE},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.PUSH_BACK},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_LINE, 'action_type': ActionType.PULL_FRONT},
		],
		'civilians': [
			{'scene': 0, 'health': 3, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE},
			{'scene': 0, 'health': 3, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE},
		],
		'max_turns': 5
	},
	{
		'map_scene': 2,
		'players': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.PUSH_BACK},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_DOT, 'action_type': ActionType.GIVE_SHIELD},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_LINE, 'action_type': ActionType.PULL_FRONT},
		],
		'enemies': [
			{'scene': 0, 'health': 4, 'damage': 2, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_DOT, 'action_type': ActionType.NONE},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_LINE, 'action_type': ActionType.PUSH_BACK},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.PULL_FRONT},
		],
		'civilians': [
			{'scene': 0, 'health': 3, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE},
			{'scene': 0, 'health': 3, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE},
			{'scene': 0, 'health': 3, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE},
		],
		'max_turns': 5
	},
]
const MAPS_FILE_PATH: String = 'res://Data/maps.txt'

var tutorial: bool = true

var level: int
var max_levels: int
var current_turn: int
var max_turns: int
var undos: Array
var points: int
var selected_player: Node3D
var map: Node3D
var players: Array[Node3D]
var enemies: Array[Node3D]
var civilians: Array[Node3D]


func _ready():
	if tutorial:
		level = 1
	else:
		level = 5
	
	max_levels = LEVELS_DATA.size()
	points = 0


func init():
	var current_level_data = LEVELS_DATA[level - 1]
	
	init_game_state(current_level_data)
	init_map(current_level_data)
	init_players(current_level_data)
	init_enemies(current_level_data)
	init_civilians(current_level_data)
	
	start_turn()


func init_game_state(current_level_data):
	current_turn = 1
	max_turns = current_level_data.max_turns
	# TODO
	undos = []
	selected_player = null
	
	# UI
	reset_ui()
	end_turn_button.set_disabled(true)
	shoot_button.set_disabled(true)
	action_button.set_disabled(true)
	level_end_label.text = ''
	level_end_popup.hide()


func init_map(current_level_data):
	map = map_scenes[current_level_data.map_scene].instantiate()
	add_sibling(map)
	map.spawn(MAPS_FILE_PATH, level)
	
	for tile in map.tiles:
		tile.connect('hovered_event', _on_tile_hovered)
		tile.connect('clicked_event', _on_tile_clicked)


func init_players(current_level_data):
	players = []
	
	for current_level_player in current_level_data.players:
		var current_player: Node3D = player_scenes[current_level_player.scene].instantiate()
		add_sibling(current_player)
		current_player.init(current_level_player)
		var spawn_tile = map.get_available_tiles().pick_random()
		current_player.spawn(spawn_tile)
		
		current_player.connect('hovered_event', _on_player_hovered)
		current_player.connect('clicked_event', _on_player_clicked)
		current_player.connect('action_push_back', _on_character_action_push_back)
		current_player.connect('action_pull_front', _on_character_action_pull_front)
		current_player.connect('action_miss_action', _on_character_action_miss_action)
		current_player.connect('action_hit_ally', _on_character_action_hit_ally)
		current_player.connect('action_give_shield', _on_character_action_give_shield)
		current_player.connect('action_slow_down', _on_character_action_slow_down)
		
		players.push_back(current_player)


func init_enemies(current_level_data):
	enemies = []
	
	for current_level_enemy in current_level_data.enemies:
		var current_enemy: Node3D = enemy_scenes[current_level_enemy.scene].instantiate()
		add_sibling(current_enemy)
		current_enemy.init(current_level_enemy)
		var spawn_tile = map.get_available_tiles().pick_random()
		current_enemy.spawn(spawn_tile)
		
		current_enemy.connect('action_push_back', _on_character_action_push_back)
		current_enemy.connect('action_pull_front', _on_character_action_pull_front)
		current_enemy.connect('action_miss_action', _on_character_action_miss_action)
		current_enemy.connect('action_hit_ally', _on_character_action_hit_ally)
		current_enemy.connect('action_give_shield', _on_character_action_give_shield)
		current_enemy.connect('action_slow_down', _on_character_action_slow_down)
		
		enemies.push_back(current_enemy)


func init_civilians(current_level_data):
	civilians = []
	
	for current_level_civilian in current_level_data.civilians:
		var current_civilian: Node3D = civilian_scenes[current_level_civilian.scene].instantiate()
		add_sibling(current_civilian)
		current_civilian.init(current_level_civilian)
		var spawn_tile = map.get_available_tiles().pick_random()
		current_civilian.spawn(spawn_tile)
		
		current_civilian.connect('action_push_back', _on_character_action_push_back)
		current_civilian.connect('action_pull_front', _on_character_action_pull_front)
		current_civilian.connect('action_miss_action', _on_character_action_miss_action)
		current_civilian.connect('action_hit_ally', _on_character_action_hit_ally)
		current_civilian.connect('action_give_shield', _on_character_action_give_shield)
		current_civilian.connect('action_slow_down', _on_character_action_slow_down)
		
		civilians.push_back(current_civilian)


func start_turn():
	var alive_civilians = civilians.filter(func(civilian): return civilian.is_alive)
	var alive_enemies = enemies.filter(func(enemy): return enemy.is_alive)
	var alive_players = players.filter(func(player): return player.is_alive)
	
	for civilian in alive_civilians:
		var tiles_for_movement = calculate_tiles_for_movement(true, civilian)
		var target_tiles_for_movement
		if tiles_for_movement.size() > 1:
			target_tiles_for_movement = tiles_for_movement.filter(func(tile_for_movement): return tile_for_movement != civilian.tile)
		else:
			target_tiles_for_movement = tiles_for_movement
		
		var target_tile_for_movement = target_tiles_for_movement.pick_random()
		var tiles_path = calculate_tiles_path(civilian.tile, target_tile_for_movement)
		await civilian.move(tiles_path, false)
	
	for enemy in alive_enemies:
		var tiles_for_movement = calculate_tiles_for_movement(true, enemy)
		var target_tile_for_movement = calculate_tile_for_movement_towards_characters(tiles_for_movement, enemy, alive_civilians + alive_players)
		#var target_tile_for_movement = calculate_tile_for_movement_towards_characters(tiles_for_movement, enemy, alive_civilians)
		#if not target_tile_for_movement:
			#target_tile_for_movement = calculate_tile_for_movement_towards_characters(tiles_for_movement, enemy, alive_players)
		if not target_tile_for_movement:
			target_tile_for_movement = tiles_for_movement.pick_random()
		
		var tiles_path = calculate_tiles_path(enemy.tile, target_tile_for_movement)
		await enemy.move(tiles_path, false)
		
		var tiles_for_action = calculate_tiles_for_action(true, enemy)
		var target_tile_for_action = calculate_tile_for_action_towards_characters(tiles_for_action, alive_civilians + alive_players)
		#var target_tile_for_action = calculate_tile_for_action_towards_characters(tiles_for_action, alive_civilians)
		#if not target_tile_for_action:
			#target_tile_for_action = calculate_tile_for_action_towards_characters(tiles_for_action, alive_players)
		if not target_tile_for_action:
			target_tile_for_action = tiles_for_action.pick_random()
			
		enemy.plan_action(target_tile_for_action)
	
	for player in alive_players:
		player.start_turn()
	
	# UI
	end_turn_button.set_disabled(false)


func end_turn():
	# UI
	end_turn_button.set_disabled(true)
	
	for player in players.filter(func(player): return player.is_alive):
		#player.reset_phase()
		player.reset_tiles()
		player.reset_states()
		player.current_phase = PhaseType.WAIT
	
	for enemy in enemies:
		# enemy could have been killed by another enemy inside this loop
		if enemy.is_alive:
			var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(enemy, enemy.planned_tile.coords)
			if first_occupied_tile_in_line:
				enemy.plan_action(first_occupied_tile_in_line)
			
			await enemy.execute_planned_action()
	
	
	if enemies.filter(func(enemy): return enemy.is_alive).is_empty():
		level_won()
	
	if players.filter(func(player): return player.is_alive).is_empty():# or civilians.filter(func(civilian): return civilian.is_alive).is_empty():
		level_lost()
	else:
		next_turn()
	#elif current_turn < max_turns:
		#next_turn()
	#else:
		#level_won()


func next_turn():
	current_turn += 1
	
	# UI
	game_info.text = 'LEVEL: ' + str(level) + '\n'
	game_info.text += 'TURN: ' + str(current_turn) + '\n'
	game_info.text += 'POINTS: ' + str(points)
	
	start_turn()


func next_level():
	map.queue_free()
	
	for player in players:
		player.queue_free()
	
	for enemy in enemies:
		enemy.queue_free()
	
	for civilian in civilians:
		civilian.queue_free()
	
	level += 1
	
	init()


func level_won():
	points += civilians.filter(func(civilian): return civilian.is_alive).size()
	
	if level < max_levels:
		level_end_label.text = 'LEVEL WON'
		level_end_popup.show()
		#next_level()
	else:
		print('WINNER WINNER!!!')


func level_lost():
	level_end_label.text = 'LEVEL LOST'
	level_end_popup.show()


func reset_ui():
	game_info.text = 'LEVEL: ' + str(level) + '\n'
	game_info.text += 'TURN: ' + str(current_turn) + '\n'
	game_info.text += 'POINTS: ' + str(points)
	tile_info.text = ''


func calculate_tiles_for_movement(active, character):
	var tiles_for_movement
	
	if active:
		tiles_for_movement = [character.tile]
		var i = 1
		
		# don't even ask how this works
		var origin_tiles = [character.tile]
		var move_distance
		if character.state_type == StateType.SLOW_DOWN:
			move_distance = 1
		else:
			move_distance = character.move_distance
		
		while i <= move_distance:
			var temp_origin_tiles = []
			
			for origin_tile in origin_tiles:
				for tile in map.tiles.filter(func(tile): return not tile.player and not tile.enemy and not tile.civilian and not tiles_for_movement.has(tile)):
					if is_tile_adjacent(tile, origin_tile, true):
						push_unique_to_array(tiles_for_movement, tile)
						push_unique_to_array(temp_origin_tiles, tile)
					elif is_tile_adjacent(tile, origin_tile, not character.can_fly):
						push_unique_to_array(temp_origin_tiles, tile)
			
			origin_tiles = temp_origin_tiles
			i += 1
	else:
		tiles_for_movement = map.tiles#.filter(func(tile): return tile.health_type != TileHealthType.DESTROYED and tile.health_type == TileHealthType.INDESTRUCTIBLE)
	
	return tiles_for_movement


func calculate_tiles_path(origin_tile, target_tile):
	var map_dimension = map.get_side_dimension()
	var astar_grid_map = AStarGrid2D.new()
	astar_grid_map.region = Rect2i(1, 1, map_dimension, map_dimension)
	astar_grid_map.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid_map.update()
	
	for occupied_tile in map.get_occupied_tiles():
		astar_grid_map.set_point_solid(occupied_tile.coords, true)
	
	var tiles_coords_path = astar_grid_map.get_id_path(origin_tile.coords, target_tile.coords)
	if tiles_coords_path.size() > 1:
		tiles_coords_path.erase(origin_tile.coords)
	
	return tiles_coords_path.map(func(tile_coords): return map.tiles.filter(func(tile): return tile.coords == tile_coords).front())


func is_tile_adjacent(tile, origin_tile, check_for_movement):
	if check_for_movement and (tile.health_type == TileHealthType.DESTROYED or tile.health_type == TileHealthType.INDESTRUCTIBLE):
		return false
	
	return abs(tile.coords - origin_tile.coords) == Vector2i(0, 1) or abs(tile.coords - origin_tile.coords) == Vector2i(1, 0)


func calculate_tiles_for_action(active, character):
	var origin_tile = character.tile
	var tiles_for_action
	
	if active:
		tiles_for_action = []
		
		if character.action_direction == ActionDirection.HORIZONTAL_LINE or character.action_direction == ActionDirection.HORIZONTAL_DOT:
			for tile in map.tiles.filter(func(tile): return not tile.coords == character.tile.coords):
				if tile.coords.x == origin_tile.coords.x or tile.coords.y == origin_tile.coords.y:
					push_unique_to_array(tiles_for_action, tile)
		elif character.action_direction == ActionDirection.VERTICAL_LINE or character.action_direction == ActionDirection.VERTICAL_DOT:
			# FIXME maybe
			for i in range(1, 9):
				var counter = 0
				for tile in map.tiles.filter(func(tile): return not tiles_for_action.has(tile)):
					if abs(tile.coords - origin_tile.coords) == Vector2i(i, i):# or tile.coords - origin_tile.coords == Vector2i(-i, -i):
						push_unique_to_array(tiles_for_action, tile)
						counter += 1
						
						# only four tiles can have proper coords for given 'i'
						if counter == 4:
							break
	else:
		tiles_for_action = map.tiles#.filter(func(tile): return tile.health_type != TileHealthType.DESTROYED and tile.health_type == TileHealthType.INDESTRUCTIBLE)
	
	return tiles_for_action


func calculate_tile_for_movement_towards_characters(tiles_for_movement, origin_character, target_characters):
	# make it random
	tiles_for_movement.shuffle()
	target_characters.shuffle()
	
	if tiles_for_movement.has(origin_character.tile):
		# prefer to move (origin character tile at the last position)
		tiles_for_movement.erase(origin_character.tile)
		tiles_for_movement.push_back(origin_character.tile)
	
	for tile_for_movement in tiles_for_movement:
		if origin_character.action_direction == ActionDirection.HORIZONTAL_LINE or origin_character.action_direction == ActionDirection.HORIZONTAL_DOT:
			if target_characters.any(func(target_character): return target_character.tile.coords.x == tile_for_movement.coords.x or target_character.tile.coords.y == tile_for_movement.coords.y):
				return tile_for_movement
		
		if origin_character.action_direction == ActionDirection.VERTICAL_LINE or origin_character.action_direction == ActionDirection.VERTICAL_DOT:
			# FIXME maybe
			var shuffled_range = range(1, 9)
			shuffled_range.shuffle()
			for i in shuffled_range:
				if target_characters.any(func(target_character): return target_character.tile.coords - tile_for_movement.coords == Vector2i(i, i) or target_character.tile.coords - tile_for_movement.coords == Vector2i(-i, -i)):
					return tile_for_movement
	
	return null


func calculate_tile_for_action_towards_characters(tiles_for_action, target_characters):
	# make it random
	tiles_for_action.shuffle()
	target_characters.shuffle()
	
	for tile_for_action in tiles_for_action:
		if target_characters.any(func(target_character): return target_character.tile.coords == tile_for_action.coords):
			return tile_for_action
	
	return null


func calculate_first_occupied_tile_for_action_direction_line(character, target_tile_coords):
	if character.action_direction == ActionDirection.HORIZONTAL_LINE:
		var hit_direction = (target_tile_coords - character.tile.coords).sign()
		var max_tiles_in_line
		# direction from origin to target
		if hit_direction == Vector2i(1, 0):
			#print('DOWN (LEFT)')
			max_tiles_in_line = map.get_side_dimension() - character.tile.coords.x
		elif hit_direction == Vector2i(-1, 0):
			#print('UP (RIGHT)')
			max_tiles_in_line = character.tile.coords.x - 1
		elif hit_direction == Vector2i(0, 1):
			#print('RIGHT (DOWN)')
			max_tiles_in_line = map.get_side_dimension() - character.tile.coords.y
		elif hit_direction == Vector2i(0, -1):
			#print('LEFT (UP)')
			max_tiles_in_line = character.tile.coords.y - 1
		
		var tiles_in_line = []
		for i in range(1, max_tiles_in_line + 1):
			var current_tiles_in_line = map.tiles.filter(func(tile): return tile.coords == character.tile.coords + hit_direction * i)
			if not current_tiles_in_line.is_empty():
				push_unique_to_array(tiles_in_line, current_tiles_in_line.front())
		
		var occupied_tiles_in_line = tiles_in_line.filter(func(tile_in_line): return tile_in_line.health_type == TileHealthType.INDESTRUCTIBLE or tile_in_line.player or tile_in_line.enemy or tile_in_line.civilian)
		if not occupied_tiles_in_line.is_empty():
			return occupied_tiles_in_line.front()
		
		return tiles_in_line.back()
	
	if character.action_direction == ActionDirection.VERTICAL_LINE:
		var hit_direction = (target_tile_coords - character.tile.coords).sign()
		var max_tiles_in_line
		if hit_direction == Vector2i(1, 1):
			#print('DOWN')
			max_tiles_in_line = map.get_side_dimension() - maxi(character.tile.coords.x, character.tile.coords.y)
		elif hit_direction == Vector2i(-1, -1):
			#print('UP')
			max_tiles_in_line = mini(character.tile.coords.x, character.tile.coords.y) - 1
		elif hit_direction == Vector2i(-1, 1):
			#print('RIGHT')
			if character.tile.coords.x + character.tile.coords.y < 10:
				max_tiles_in_line = character.tile.coords.x - 1
			else:
				max_tiles_in_line = character.tile.coords.x - 1 - (map.get_side_dimension() - map.get_horizontal_diagonal_dimension(character.tile.coords))
		elif hit_direction == Vector2i(1, -1):
			#print('LEFT')
			if character.tile.coords.x + character.tile.coords.y < 10:
				max_tiles_in_line = character.tile.coords.y - 1
			else:
				max_tiles_in_line = character.tile.coords.y - 1 - (map.get_side_dimension() - map.get_horizontal_diagonal_dimension(character.tile.coords))
		
		var tiles_in_line = []
		for i in range(1, max_tiles_in_line + 1):
			var current_tiles_in_line = map.tiles.filter(func(tile): return tile.coords - character.tile.coords == hit_direction * i)
			if not current_tiles_in_line.is_empty():
				push_unique_to_array(tiles_in_line, current_tiles_in_line.front())
		
		var occupied_tiles_in_line = tiles_in_line.filter(func(tile_in_line): return tile_in_line.health_type == TileHealthType.INDESTRUCTIBLE or tile_in_line.player or tile_in_line.enemy or tile_in_line.civilian)
		if not occupied_tiles_in_line.is_empty():
			return occupied_tiles_in_line.front()
		
		return tiles_in_line.back()
	
	return null


func on_shoot_action_button_toggled(toggled_on):
	if toggled_on:
		if selected_player.current_phase == PhaseType.MOVE and not selected_player.no_more_actions_this_turn():
			selected_player.current_phase = PhaseType.ACTION
	else:
		if selected_player.current_phase == PhaseType.ACTION and not selected_player.no_more_moves_this_turn():
			selected_player.current_phase = PhaseType.MOVE
	
	# remember selected player to be able to unlick and click it again
	var player = selected_player
	player.reset_tiles()
	player.clicked()


func _on_tile_hovered(tile, is_hovered):
	if is_hovered:
		# info about clicked tile
		tile_info.text = 'COORDS: ' + str(tile.coords) + '\n'
		tile_info.text += 'HEALTH TYPE: ' + str(TileHealthType.keys()[tile.health_type]) + '\n'
		tile_info.text += 'TILE TYPE: ' + str(TileType.keys()[tile.tile_type])
		
		if tile.player:
			tile_info.text += '\n' + 'HEALTH: ' + str(tile.player.health) + '\n'
			tile_info.text += '\n' + 'ACTION TYPE: ' + str(ActionType.keys()[tile.player.action_type]) + '\n'
			tile_info.text += 'ACTION DIRECTION: ' + str(ActionDirection.keys()[tile.player.action_direction]) + '\n'
			tile_info.text += 'MOVE DISTANCE: ' + str(tile.player.move_distance)
		if tile.enemy:
			tile_info.text += '\n' + 'HEALTH: ' + str(tile.enemy.health) + '\n'
			tile_info.text += '\n' + 'ACTION TYPE: ' + str(ActionType.keys()[tile.enemy.action_type]) + '\n'
			tile_info.text += 'ACTION DIRECTION: ' + str(ActionDirection.keys()[tile.enemy.action_direction]) + '\n'
			tile_info.text += 'MOVE DISTANCE: ' + str(tile.enemy.move_distance)
		if tile.civilian:
			tile_info.text += '\n' + 'HEALTH: ' + str(tile.civilian.health) + '\n'
			tile_info.text += '\n' + 'MOVE DISTANCE: ' + str(tile.civilian.move_distance)
	else:
		tile_info.text = ''
	
	# highlight tiles while player is hovered
	if selected_player and selected_player.tile != tile and tile.is_player_clicked and selected_player.current_phase == PhaseType.MOVE:
		var tiles_path = calculate_tiles_path(selected_player.tile, tile)
		# different color for the hovered (target) tile
		tiles_path.erase(tile)
		
		var color
		if is_hovered:
			color = Color.REBECCA_PURPLE
		else:
			color = Color.PURPLE
		
		for current_tile in tiles_path:
			current_tile.color_model(color)


func _on_tile_clicked(tile, is_clicked):
	#for other_tile in map.tiles.filter(func(t): return t != tile and t.is_clicked):
		#other_tile.is_clicked = false
	
	#if is_clicked:
		## info about clicked tile
		## FIXME może zmiana na hover?
		#tile_info.text = 'COORDS: ' + str(tile.coords) + '\n'
		#tile_info.text += 'HEALTH TYPE: ' + str(TileHealthType.keys()[tile.health_type]) + '\n'
		#tile_info.text += 'TILE TYPE: ' + str(TileType.keys()[tile.tile_type])
		#
		#if tile.player:
			#tile_info.text += '\n' + 'HEALTH: ' + str(tile.player.health) + '\n'
			#tile_info.text += '\n' + 'ACTION TYPE: ' + str(ActionType.keys()[tile.player.action_type]) + '\n'
			#tile_info.text += 'ACTION DIRECTION: ' + str(ActionDirection.keys()[tile.player.action_direction]) + '\n'
			#tile_info.text += 'MOVE DISTANCE: ' + str(tile.player.move_distance)
		#if tile.enemy:
			#tile_info.text += '\n' + 'HEALTH: ' + str(tile.enemy.health) + '\n'
			#tile_info.text += '\n' + 'ACTION TYPE: ' + str(ActionType.keys()[tile.enemy.action_type]) + '\n'
			#tile_info.text += 'ACTION DIRECTION: ' + str(ActionDirection.keys()[tile.enemy.action_direction]) + '\n'
			#tile_info.text += 'MOVE DISTANCE: ' + str(tile.enemy.move_distance)
		#if tile.civilian:
			#tile_info.text += '\n' + 'HEALTH: ' + str(tile.civilian.health) + '\n'
			#tile_info.text += '\n' + 'MOVE DISTANCE: ' + str(tile.civilian.move_distance)
	#else:
		#tile_info.text = ''
	
	# highlighted tile is clicked while player is selected
	if selected_player and selected_player.tile != tile and tile.is_player_clicked:
		if selected_player.current_phase == PhaseType.MOVE:
			var tiles_path = calculate_tiles_path(selected_player.tile, tile)
			await selected_player.move(tiles_path, false)
		elif selected_player.current_phase == PhaseType.ACTION:
			var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(selected_player, tile.coords)
			if first_occupied_tile_in_line:
				tile = first_occupied_tile_in_line
			
			if action_button.is_pressed():
				await selected_player.execute_action(tile)
			else:
				await selected_player.shoot(tile)
			
			if enemies.filter(func(enemy): return enemy.is_alive).is_empty():
				level_won()
	# other player or selected player is clicked
	elif tile.player and (not selected_player or selected_player.tile == tile or selected_player.can_be_interacted_with()):
		tile.player.reset_phase()
		tile.player.on_clicked()
		shoot_button.set_pressed_no_signal(tile.player.current_phase == PhaseType.ACTION)
		action_button.set_pressed_no_signal(false)


func _on_player_hovered(player, is_hovered):
	if selected_player and selected_player != player:
		return
	
	if player.current_phase == PhaseType.MOVE:
		var tiles_for_movement = calculate_tiles_for_movement(is_hovered, player)
		for tile_for_movement in tiles_for_movement:
			tile_for_movement.toggle_player_hovered(is_hovered)
	elif player.current_phase == PhaseType.ACTION:
		var tiles_for_action = calculate_tiles_for_action(is_hovered, player)
		for tile_for_action in tiles_for_action:
			tile_for_action.toggle_player_hovered(is_hovered)


func _on_player_clicked(player, is_clicked):
	# reset tiles for selected player if new player is selected
	if selected_player and selected_player != player and selected_player.can_be_interacted_with():
		selected_player.reset_tiles()
	
	if is_clicked:
		selected_player = player
		
		# UI
		shoot_button.set_disabled(false)
		action_button.set_disabled(selected_player.action_type == ActionType.NONE)
		if not action_button.is_pressed() and selected_player.current_phase == PhaseType.ACTION:
			shoot_button.set_pressed_no_signal(true)
	else:
		selected_player = null
		
		# UI
		shoot_button.set_disabled(true)
		action_button.set_disabled(true)
	
	if player.current_phase == PhaseType.MOVE:
		var tiles_for_movement = calculate_tiles_for_movement(is_clicked, player)
		for tile_for_movement in tiles_for_movement:
			tile_for_movement.toggle_player_clicked(is_clicked)
	elif player.current_phase == PhaseType.ACTION:
		var tiles_for_action = calculate_tiles_for_action(is_clicked, player)
		for tile_for_action in tiles_for_action:
			tile_for_action.toggle_player_clicked(is_clicked)


func _on_character_action_push_back(character, origin_tile_coords):
	var hit_direction = (origin_tile_coords - character.tile.coords).sign()
	var push_direction = -hit_direction
	#var target_tiles = map.get_available_tiles().filter(func(available_tile): return available_tile.coords == character.tile.coords + push_direction)
	var available_tiles = map.tiles.filter(func(tile): return tile.health_type != TileHealthType.INDESTRUCTIBLE)
	var target_tiles = available_tiles.filter(func(available_tile): return available_tile.coords == character.tile.coords + push_direction)
	if target_tiles.is_empty():
		# pushed outside of the map
		await character.move([character.tile], true)
	else:
		var target_tile = target_tiles.front()
		await character.move([target_tile], true)
		
		if character.is_alive and character.tile:
			if character.tile.health_type == TileHealthType.DESTROYED:
				# fell down
				character.get_killed()
			elif character.tile == target_tile and character.is_in_group('ENEMIES') and character.planned_tile:
				var enemy = character
				# push planned tile with pushed enemy
				target_tiles = map.tiles.filter(func(tiles): return tiles.coords == enemy.planned_tile.coords + push_direction)
				if target_tiles.is_empty():
					print(str(enemy.tile.coords) + 'enemy: planned tile cannot be pushed back')
				else:
					enemy.plan_action(target_tile)


func _on_character_action_pull_front(character, origin_tile_coords):
	var hit_direction = (origin_tile_coords - character.tile.coords).sign()
	var pull_direction = hit_direction
	#var target_tiles = map.get_available_tiles().filter(func(available_tile): return available_tile.coords == character.tile.coords + pull_direction)
	var available_tiles = map.tiles.filter(func(tile): return tile.health_type != TileHealthType.INDESTRUCTIBLE)
	var target_tiles = available_tiles.filter(func(available_tile): return available_tile.coords == character.tile.coords + pull_direction)
	if target_tiles.is_empty():
		# pulled outside of the map - is this even possible?
		await character.move([character.tile], true)
	else:
		var target_tile = target_tiles.front()
		await character.move([target_tiles.front()], true)
		
		if character.is_alive and character.tile:
			if character.tile.health_type == TileHealthType.DESTROYED:
				# fell down
				character.get_killed()
			elif character.tile == target_tile and character.is_in_group('ENEMIES') and character.planned_tile:
				var enemy = character
				# pull planned tile with pulled enemy
				target_tiles = map.tiles.filter(func(tiles): return tiles.coords == enemy.planned_tile.coords + pull_direction)
				if target_tiles.is_empty():
					print(str(enemy.tile.coords) + 'enemy: planned tile cannot be pulled front')
				else:
					enemy.plan_action(target_tiles.front())


func _on_character_action_miss_action(character):
	character.state_type = StateType.MISS_ACTION
	
	if character.is_in_group('ENEMIES') and character.planned_tile:
		var enemy = character
		enemy.planned_tile.set_planned_enemy_action(false)
		enemy.planned_tile = null


func _on_character_action_hit_ally(character):
	character.state_type = StateType.HIT_ALLY


func _on_character_action_give_shield(character):
	character.state_type = StateType.GIVE_SHIELD


func _on_character_action_slow_down(character):
	character.state_type = StateType.SLOW_DOWN


func _on_end_turn_button_pressed():
	end_turn()


func _on_shoot_button_toggled(toggled_on):
	#if toggled_on:
		#action_button.set_pressed_no_signal(false)
	
	on_shoot_action_button_toggled(toggled_on)


func _on_action_button_toggled(toggled_on):
	#if toggled_on:
		#shoot_button.set_pressed_no_signal(false)
	
	on_shoot_action_button_toggled(toggled_on)


func _on_level_end_popup_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		level_end_popup.hide()
		level_end_label.text = ''
		
		next_level()
