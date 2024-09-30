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
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.PUSH_BACK, 'action_distance': 3},
		],
		'enemies': [
			{'scene': 0, 'health': 2, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 3},
		],
		'civilians': [],
		'max_turns': 5
	},
	{
		'map_scene': 0,
		'players': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.PUSH_BACK, 'action_distance': 3},
		],
		'enemies': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 2, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 3},
		],
		'civilians': [
			{'scene': 0, 'health': 3, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
		],
		'max_turns': 5
	},
	{
		# 6x6
		'map_scene': 1,
		'players': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.NONE, 'action_distance': 5},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.PULL_FRONT, 'action_distance': 5},
		],
		'enemies': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_LINE, 'action_type': ActionType.PUSH_BACK, 'action_distance': 5},
		],
		'civilians': [
			{'scene': 0, 'health': 3, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
		],
		'max_turns': 5
	},
	{
		'map_scene': 1,
		'players': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.NONE, 'action_distance': 5},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_LINE, 'action_type': ActionType.PUSH_BACK, 'action_distance': 5},
		],
		'enemies': [
			{'scene': 0, 'health': 3, 'damage': 2, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 5},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_DOT, 'action_type': ActionType.PULL_FRONT, 'action_distance': 5},
		],
		'civilians': [
			{'scene': 0, 'health': 3, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
		],
		'max_turns': 5
	},
	{
		# 8x8
		'map_scene': 2,
		'players': [
			{'scene': 0, 'health': 3, 'damage': 2, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 7},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.PUSH_BACK, 'action_distance': 7},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_LINE, 'action_type': ActionType.PULL_FRONT, 'action_distance': 7},
		],
		'enemies': [
			{'scene': 0, 'health': 4, 'damage': 2, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.NONE, 'action_distance': 7},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.PUSH_BACK, 'action_distance': 7},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.VERTICAL_LINE, 'action_type': ActionType.PULL_FRONT, 'action_distance': 7},
		],
		'civilians': [
			{'scene': 0, 'health': 3, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
			{'scene': 0, 'health': 3, 'damage': 0, 'move_distance': 1, 'can_fly': false, 'action_direction': ActionDirection.NONE, 'action_type': ActionType.NONE, 'action_distance': 0},
		],
		'max_turns': 5
	},
	{
		'map_scene': 2,
		'players': [
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.PUSH_BACK},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.GIVE_SHIELD},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.PULL_FRONT},
		],
		'enemies': [
			{'scene': 0, 'health': 4, 'damage': 2, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_DOT, 'action_type': ActionType.NONE},
			{'scene': 0, 'health': 3, 'damage': 1, 'move_distance': 3, 'can_fly': false, 'action_direction': ActionDirection.HORIZONTAL_LINE, 'action_type': ActionType.PUSH_BACK},
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

var tutorial: bool = false

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
		var current_player = player_scenes[current_level_player.scene].instantiate()
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
	
	var order = 1
	for current_level_enemy in current_level_data.enemies:
		var current_enemy = enemy_scenes[current_level_enemy.scene].instantiate()
		add_sibling(current_enemy)
		current_enemy.init(current_level_enemy)
		var spawn_tile = map.get_available_tiles().pick_random()
		current_enemy.spawn(spawn_tile, order)
		
		current_enemy.connect('action_push_back', _on_character_action_push_back)
		current_enemy.connect('action_pull_front', _on_character_action_pull_front)
		current_enemy.connect('action_miss_action', _on_character_action_miss_action)
		current_enemy.connect('action_hit_ally', _on_character_action_hit_ally)
		current_enemy.connect('action_give_shield', _on_character_action_give_shield)
		current_enemy.connect('action_slow_down', _on_character_action_slow_down)
		
		enemies.push_back(current_enemy)
		
		order += 1


func init_civilians(current_level_data):
	civilians = []
	
	for current_level_civilian in current_level_data.civilians:
		var current_civilian = civilian_scenes[current_level_civilian.scene].instantiate()
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
		if tiles_for_movement.is_empty():
			tiles_for_movement.push_back(civilian.tile)
		
		var target_tiles_for_movement
		if tiles_for_movement.size() == 1:
			target_tiles_for_movement = tiles_for_movement
		else:
			# prefer to move if possible
			target_tiles_for_movement = tiles_for_movement.filter(func(tile): return tile != civilian.tile)
		
		var target_tile_for_movement = target_tiles_for_movement.pick_random()
		var tiles_path = calculate_tiles_path(civilian, target_tile_for_movement)
		await civilian.move(tiles_path, false, null)
		
		# recalculate_enemies_planned_actions is not necessary because civilians move before enemies plan their actions
	
	# sort by order
	alive_enemies.sort_custom(func(e1, e2): return e1.order < e2.order)
	for enemy in alive_enemies:
		var tiles_for_movement = calculate_tiles_for_movement(true, enemy)
		tiles_for_movement.push_back(enemy.tile)
			
		var target_tile_for_movement = calculate_tile_for_movement_towards_characters(tiles_for_movement, enemy, alive_civilians + alive_players)
		if not target_tile_for_movement:
			target_tile_for_movement = tiles_for_movement.pick_random()
			print('enemy ' + str(enemy.tile.coords) + ' -> random move: ' + str(target_tile_for_movement.coords))
		
		var tiles_path = calculate_tiles_path(enemy, target_tile_for_movement)
		await enemy.move(tiles_path, false, null)
	
		# enemy could have moved in front of the other enemy's attack line
		recalculate_enemies_planned_actions()
		
		var tiles_for_action = calculate_tiles_for_action(true, enemy)
		var target_tile_for_action = calculate_tile_for_action_towards_characters(tiles_for_action, alive_civilians + alive_players)
		if not target_tile_for_action:
			# no friendly fire prefered
			# TODO uwzględnij że przy _LINE wróg zasłaniać wybrany tile
			var no_ff_tiles = tiles_for_action.filter(func(tile): return not tile.enemy)
			if no_ff_tiles.is_empty():
				target_tile_for_action = tiles_for_action.pick_random()
			else:
				target_tile_for_action = no_ff_tiles.pick_random()
		
		enemy.plan_action(target_tile_for_action)
	
	for player in alive_players:
		player.start_turn()
	
	# UI
	end_turn_button.set_disabled(false)


func end_turn():
	# UI
	end_turn_button.set_disabled(true)
	shoot_button.set_pressed_no_signal(false)
	action_button.set_pressed_no_signal(false)
	
	for player in players.filter(func(player): return player.is_alive):
		#player.reset_phase()
		player.reset_tiles()
		player.reset_states()
		player.current_phase = PhaseType.WAIT
	
	# sort by order
	enemies.sort_custom(func(e1, e2): return e1.order < e2.order)
	for enemy in enemies:
		# enemy could have been killed by another enemy inside this loop
		if enemy.is_alive:
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
	
	# still in tutorial
	if level < 5:
		# TODO achievements
		print('achievement unlocked: you are a game journalist now')


func reset_ui():
	game_info.text = 'LEVEL: ' + str(level) + '\n'
	game_info.text += 'TURN: ' + str(current_turn) + '\n'
	game_info.text += 'POINTS: ' + str(points)
	tile_info.text = ''


func calculate_tiles_for_movement(active, character):
	var tiles_for_movement = []
	
	if active:
		#tiles_for_movement.push_back(character.tile)
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
				for tile in map.tiles:
					# characters can move through other characters of the same type
					var occupied_by_characters = (not character.is_in_group('PLAYERS') and tile.player) or (not character.is_in_group('ENEMIES') and tile.enemy) or (not character.is_in_group('CIVILIANS') and tile.civilian)
					if not occupied_by_characters and not tiles_for_movement.has(tile):
						if is_tile_adjacent(tile, origin_tile, true):
							push_unique_to_array(tiles_for_movement, tile)
							push_unique_to_array(temp_origin_tiles, tile)
						elif is_tile_adjacent(tile, origin_tile, not character.can_fly):
							push_unique_to_array(temp_origin_tiles, tile)
			
			origin_tiles = temp_origin_tiles
			i += 1
	else:
		return map.tiles
	
	# remove occupied tiles as target movement tiles
	return tiles_for_movement.filter(func(tile): return not tile.player and not tile.enemy and not tile.civilian)


func is_tile_adjacent(tile, origin_tile, check_for_movement):
	if check_for_movement and (tile.health_type == TileHealthType.DESTROYED or tile.health_type == TileHealthType.DESTRUCTIBLE or tile.health_type == TileHealthType.INDESTRUCTIBLE):
		return false
	
	return abs(tile.coords - origin_tile.coords) == Vector2i(0, 1) or abs(tile.coords - origin_tile.coords) == Vector2i(1, 0)


func calculate_tiles_path(character, target_tile):
	var map_dimension = map.get_side_dimension()
	var astar_grid_map = AStarGrid2D.new()
	astar_grid_map.region = Rect2i(1, 1, map_dimension, map_dimension)
	astar_grid_map.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid_map.update()
	
	for tile in map.tiles:
		var occupied_by_health_type = tile.health_type == TileHealthType.DESTROYED or tile.health_type == TileHealthType.DESTRUCTIBLE or tile.health_type == TileHealthType.INDESTRUCTIBLE
		var occupied_by_characters = (not character.is_in_group('PLAYERS') and tile.player) or (not character.is_in_group('ENEMIES') and tile.enemy) or (not character.is_in_group('CIVILIANS') and tile.civilian)
		if occupied_by_health_type or occupied_by_characters:
			astar_grid_map.set_point_solid(tile.coords, true)
	
	var tiles_coords_path = astar_grid_map.get_id_path(character.tile.coords, target_tile.coords)
	if tiles_coords_path.size() > 1:
		tiles_coords_path.erase(character.tile.coords)
	
	if tiles_coords_path.size() > character.move_distance:
		printerr('wtf?! ' + str(tiles_coords_path) + ' ' + str(character))
	
	return tiles_coords_path.map(func(tile_coords): return map.tiles.filter(func(tile): return tile.coords == tile_coords).front())


func calculate_tiles_for_action(active, character):
	var origin_tile = character.tile
	var tiles_for_action
	
	if active:
		tiles_for_action = []
		
		if character.action_direction == ActionDirection.HORIZONTAL_LINE or character.action_direction == ActionDirection.HORIZONTAL_DOT:
			for tile in map.tiles.filter(func(tile): return not tile.coords == character.tile.coords):
				if (tile.coords.x == origin_tile.coords.x and absi(tile.coords.y - origin_tile.coords.y) <= character.action_distance) or (tile.coords.y == origin_tile.coords.y and absi(tile.coords.x - origin_tile.coords.x) <= character.action_distance):
					# include all tiles in path
					if character.is_in_group('PLAYERS'):
						push_unique_to_array(tiles_for_action, tile)
					else:
						var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(character, character.tile.coords, tile.coords)
						if not first_occupied_tile_in_line:
							first_occupied_tile_in_line = tile
						
						push_unique_to_array(tiles_for_action, first_occupied_tile_in_line)
		elif character.action_direction == ActionDirection.VERTICAL_LINE or character.action_direction == ActionDirection.VERTICAL_DOT:
			var max_range = mini(map.get_side_dimension(), character.action_distance)
			for i in range(1, max_range + 1):
				var counter = 0
				for tile in map.tiles.filter(func(tile): return not tiles_for_action.has(tile)):
					if abs(tile.coords - origin_tile.coords) == Vector2i(i, i):
						# include all tiles in path
						if character.is_in_group('PLAYERS'):
							push_unique_to_array(tiles_for_action, tile)
						else:
							var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(character, character.tile.coords, tile.coords)
							if not first_occupied_tile_in_line:
								first_occupied_tile_in_line = tile
							
							push_unique_to_array(tiles_for_action, first_occupied_tile_in_line)
						
						counter += 1
						
						# only four tiles can have valid coords for given 'i'
						if counter == 4:
							break
		
		# exclude tiles behind occupied tiles
		if character.is_in_group('PLAYERS') and character.action_direction == ActionDirection.HORIZONTAL_LINE or character.action_direction == ActionDirection.VERTICAL_LINE:
			var occupied_tiles = tiles_for_action.filter(func(tile): return tile.health_type == TileHealthType.DESTRUCTIBLE or tile.health_type == TileHealthType.INDESTRUCTIBLE or tile.player or tile.enemy or tile.civilian)
			if not occupied_tiles.is_empty():
				for occupied_tile in occupied_tiles:
					var hit_direction = (character.tile.coords - occupied_tile.coords).sign()
					var direction = get_direction(hit_direction)
					if direction == HitDirection.DOWN_LEFT:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.y != occupied_tile.coords.y or tile.coords.x <= occupied_tile.coords.x)
					elif direction == HitDirection.UP_RIGHT:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.y != occupied_tile.coords.y or tile.coords.x >= occupied_tile.coords.x)
					elif direction == HitDirection.RIGHT_DOWN:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.x != occupied_tile.coords.x or tile.coords.y <= occupied_tile.coords.y)
					elif direction == HitDirection.LEFT_UP:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.x != occupied_tile.coords.x or tile.coords.y >= occupied_tile.coords.y)
					elif direction == HitDirection.DOWN:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.x - tile.coords.y != occupied_tile.coords.x - occupied_tile.coords.y or tile.coords.x <= occupied_tile.coords.x)
					elif direction == HitDirection.UP:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.x - tile.coords.y != occupied_tile.coords.x - occupied_tile.coords.y or tile.coords.x >= occupied_tile.coords.x)
					elif direction == HitDirection.RIGHT:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.x - tile.coords.y >= occupied_tile.coords.x - occupied_tile.coords.y)
					elif direction == HitDirection.LEFT:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.x - tile.coords.y <= occupied_tile.coords.x - occupied_tile.coords.y)
	else:
		tiles_for_action = map.tiles
	
	return tiles_for_action


func calculate_tile_for_movement_towards_characters(tiles_for_movement, origin_character, target_characters):
	var target_characters_for_movement = []
	var target_tile_for_movement = null
	
	# make it random
	tiles_for_movement.shuffle()
	
	if tiles_for_movement.has(origin_character.tile):
		# prefer to move (origin character tile at the last position)
		tiles_for_movement.erase(origin_character.tile)
		tiles_for_movement.push_back(origin_character.tile)
	
	for tile_for_movement in tiles_for_movement:
		if origin_character.action_direction == ActionDirection.HORIZONTAL_LINE or origin_character.action_direction == ActionDirection.HORIZONTAL_DOT:
			target_characters_for_movement = target_characters.filter(func(target_character): return (target_character.tile.coords.x == tile_for_movement.coords.x and absi(target_character.tile.coords.y - tile_for_movement.coords.y) <= origin_character.action_distance) or (target_character.tile.coords.y == tile_for_movement.coords.y and absi(target_character.tile.coords.x - tile_for_movement.coords.x) <= origin_character.action_distance))
			if not target_characters_for_movement.is_empty():
				target_tile_for_movement = tile_for_movement
		elif origin_character.action_direction == ActionDirection.VERTICAL_LINE or origin_character.action_direction == ActionDirection.VERTICAL_DOT:
			var max_range = mini(map.get_side_dimension(), origin_character.action_distance)
			for i in range(1, max_range + 1):
				var valid_target_characters = target_characters.filter(func(target_character): return abs(target_character.tile.coords - tile_for_movement.coords) == Vector2i(i, i))
				if not valid_target_characters.is_empty():
					target_characters_for_movement.append_array(valid_target_characters)
		
			if not target_characters_for_movement.is_empty():
				target_tile_for_movement = tile_for_movement
		
		# exclude tiles behind occupied tiles
		if target_tile_for_movement and (origin_character.action_direction == ActionDirection.HORIZONTAL_LINE or origin_character.action_direction == ActionDirection.VERTICAL_LINE):
			if target_characters_for_movement.all(func(target_character): return target_character.tile != calculate_first_occupied_tile_for_action_direction_line(origin_character, target_tile_for_movement.coords, target_character.tile.coords)):
				target_characters_for_movement = []
				target_tile_for_movement = null
		
		if target_tile_for_movement:
			return target_tile_for_movement
	
	return null


func calculate_tile_for_action_towards_characters(tiles_for_action, target_characters):
	# make it random
	tiles_for_action.shuffle()
	
	for tile_for_action in tiles_for_action:
		if target_characters.any(func(target_character): return target_character.tile.coords == tile_for_action.coords):
			return tile_for_action
	
	return null


func calculate_first_occupied_tile_for_action_direction_line(origin_character, origin_tile_coords, target_tile_coords):
	if origin_character.action_direction == ActionDirection.HORIZONTAL_LINE or origin_character.action_direction == ActionDirection.VERTICAL_LINE:
		var hit_direction = (origin_tile_coords - target_tile_coords).sign()
		var tiles_in_line = []
		var max_range = mini(map.get_side_dimension(), origin_character.action_distance)
		for i in range(1, max_range + 1):
			var current_tiles_in_line = map.tiles.filter(func(tile): return tile.coords == origin_tile_coords - hit_direction * i)
			if not current_tiles_in_line.is_empty():
				push_unique_to_array(tiles_in_line, current_tiles_in_line.front())
		
		var occupied_tiles_in_line = tiles_in_line.filter(func(tile): return (tile.health_type == TileHealthType.DESTRUCTIBLE or tile.health_type == TileHealthType.INDESTRUCTIBLE or (tile.player and not tile.player.is_ghost) or tile.ghost or tile.enemy or tile.civilian) and tile != origin_character.tile)
		if not occupied_tiles_in_line.is_empty():
			return occupied_tiles_in_line.front()
		
		return tiles_in_line.back()
	
	return null


# DELETE maybe: not worth it?
#func calculate_max_tiles_in_line_for_action_direction_line(action_direction, hit_direction, character_tile_coords):
	#if action_direction == ActionDirection.HORIZONTAL_LINE:
		## direction from origin to target
		#if hit_direction == Vector2i(1, 0):
			##print('DOWN (LEFT)')
			#return map.get_side_dimension() - character_tile_coords.x
		#if hit_direction == Vector2i(-1, 0):
			##print('UP (RIGHT)')
			#return character_tile_coords.x - 1
		#if hit_direction == Vector2i(0, 1):
			##print('RIGHT (DOWN)')
			#return map.get_side_dimension() - character_tile_coords.y
		#if hit_direction == Vector2i(0, -1):
			##print('LEFT (UP)')
			#return character_tile_coords.y - 1
	#
	#if action_direction == ActionDirection.VERTICAL_LINE:
		#if hit_direction == Vector2i(1, 1):
			##print('DOWN')
			#return map.get_side_dimension() - maxi(character_tile_coords.x, character_tile_coords.y)
		#if hit_direction == Vector2i(-1, -1):
			##print('UP')
			#return mini(character_tile_coords.x, character_tile_coords.y) - 1
		#if hit_direction == Vector2i(-1, 1):
			##print('RIGHT')
			#if character_tile_coords.x + character_tile_coords.y < 10:
				#return character_tile_coords.x - 1
			#return character_tile_coords.x - 1 - (map.get_side_dimension() - map.get_horizontal_diagonal_dimension(character_tile_coords))
		#if hit_direction == Vector2i(1, -1):
			##print('LEFT')
			#if character_tile_coords.x + character_tile_coords.y < 10:
				#return character_tile_coords.y - 1
			#return character_tile_coords.y - 1 - (map.get_side_dimension() - map.get_horizontal_diagonal_dimension(character_tile_coords))


func recalculate_enemies_planned_actions():
	for enemy in enemies.filter(func(enemy): return enemy.is_alive and enemy.planned_tile):
		var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(enemy, enemy.tile.coords, enemy.planned_tile.coords)
		if first_occupied_tile_in_line:# and first_occupied_tile_in_line != enemy.planned_tile:
			enemy.plan_action(first_occupied_tile_in_line)
		# planned tile could've lost 'is_planned_enemy_action' true flag
		elif not enemy.planned_tile.is_planned_enemy_action:
			enemy.planned_tile.set_planned_enemy_action(true)


func on_shoot_action_button_toggled(toggled_on):
	# order matters here!
	if toggled_on:
		if selected_player.current_phase == PhaseType.MOVE and not selected_player.no_more_actions_this_turn():
			selected_player.current_phase = PhaseType.ACTION
	else:
		if selected_player.current_phase == PhaseType.ACTION and not selected_player.no_more_moves_this_turn():
			selected_player.current_phase = PhaseType.MOVE
	
	# remember selected player to be able to unlick and click it again
	var temp_selected_player = selected_player
	temp_selected_player.reset_tiles()
	temp_selected_player.clicked()
	
	if toggled_on and selected_player.current_phase == PhaseType.ACTION:
		var tiles_for_action = calculate_tiles_for_action(true, selected_player)
		for tile in tiles_for_action:
			tile.toggle_player_clicked(true)


func _on_tile_hovered(tile, is_hovered):
	for current_player in players:
		current_player.is_ghost = false
	
	for current_tile in map.tiles:
		current_tile.ghost = null
		
		# reset other tiles
		if current_tile != tile:
			current_tile.is_hovered = false
			current_tile.toggle_tile_models()
	
	for current_enemy in enemies:
		current_enemy.toggle_highlight(false)
	
	# UI
	if is_hovered:
		# info about hovered tile
		tile_info.text = 'COORDS: ' + str(tile.coords) + '\n'
		tile_info.text += 'HEALTH TYPE: ' + str(TileHealthType.keys()[tile.health_type]) + '\n'
		tile_info.text += 'TILE TYPE: ' + str(TileType.keys()[tile.tile_type])
		
		if tile.player:
			tile_info.text += '\n' + 'HEALTH: ' + str(tile.player.health) + '\n'
			tile_info.text += 'ACTION TYPE: ' + str(ActionType.keys()[tile.player.action_type]) + '\n'
			tile_info.text += 'ACTION DIRECTION: ' + str(ActionDirection.keys()[tile.player.action_direction]) + '\n'
			tile_info.text += 'ACTION DISTANCE: ' + str(tile.player.action_distance) + '\n'
			tile_info.text += 'MOVE DISTANCE: ' + str(tile.player.move_distance)
		
		if tile.enemy:
			tile_info.text += '\n' + 'ORDER: ' + str(tile.enemy.order) + '\n'
			tile_info.text += 'HEALTH: ' + str(tile.enemy.health) + '\n'
			tile_info.text += 'ACTION TYPE: ' + str(ActionType.keys()[tile.enemy.action_type]) + '\n'
			tile_info.text += 'ACTION DIRECTION: ' + str(ActionDirection.keys()[tile.enemy.action_direction]) + '\n'
			tile_info.text += 'ACTION DISTANCE: ' + str(tile.enemy.action_distance) + '\n'
			tile_info.text += 'MOVE DISTANCE: ' + str(tile.enemy.move_distance)
		
		if tile.civilian:
			tile_info.text += '\n' + 'HEALTH: ' + str(tile.civilian.health) + '\n'
			tile_info.text += 'MOVE DISTANCE: ' + str(tile.civilian.move_distance)
	else:
		tile_info.text = ''
	
	# highlight tiles while player is clicked
	if selected_player and selected_player.tile != tile and tile.is_player_clicked:
		if selected_player.current_phase == PhaseType.MOVE:
			#for other_tile in map.tiles.filter(func(current_tile): return current_tile != tile):
				#other_tile.toggle_tile_models()
			
			if is_hovered:
				var tiles_path = calculate_tiles_path(selected_player, tile)
				for next_tile in tiles_path:
					next_tile.on_mouse_entered()
				
				selected_player.look_at_y(tile.position)
				selected_player.is_ghost = true
				tile.ghost = selected_player
			
			recalculate_enemies_planned_actions()
		elif selected_player.current_phase == PhaseType.ACTION:
			if is_hovered:
				var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(selected_player, selected_player.tile.coords, tile.coords)
				if first_occupied_tile_in_line and first_occupied_tile_in_line != tile:
					tile.is_hovered = false
					tile.toggle_tile_models()
				
					first_occupied_tile_in_line.is_hovered = true
					first_occupied_tile_in_line.toggle_tile_models()
				else:
					first_occupied_tile_in_line = tile
				
				selected_player.look_at_y(first_occupied_tile_in_line.position)
				selected_player.spawn_arrow(first_occupied_tile_in_line)
			else:
				selected_player.clear_arrows()
	
	if is_hovered:
		if tile.enemy:
			tile.enemy.toggle_highlight(true)
		
		if tile.is_planned_enemy_action:
			for current_enemy in enemies.filter(func(enemy): return enemy.planned_tile == tile):
				current_enemy.toggle_highlight(true)


func _on_tile_clicked(tile):
	for current_player in players:
		current_player.is_ghost = false
	
	for current_tile in map.tiles:
		current_tile.ghost = null
	
	recalculate_enemies_planned_actions()
	
	# highlighted tile is clicked while player is selected
	if selected_player and selected_player.tile != tile and tile.is_player_clicked:
		if selected_player.current_phase == PhaseType.MOVE:
			var tiles_path = calculate_tiles_path(selected_player, tile)
			await selected_player.move(tiles_path, false, null)
			
			recalculate_enemies_planned_actions()
		elif selected_player.current_phase == PhaseType.ACTION:
			selected_player.clear_arrows()
		
			var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(selected_player, selected_player.tile.coords, tile.coords)
			if not first_occupied_tile_in_line:
				first_occupied_tile_in_line = tile
			
			if action_button.is_pressed():
				await selected_player.execute_action(first_occupied_tile_in_line)
			else:
				await selected_player.shoot(first_occupied_tile_in_line)
			
			if enemies.filter(func(enemy): return enemy.is_alive).is_empty():
				level_won()
	# other player or selected player is clicked
	elif tile.player and (not selected_player or selected_player.tile == tile or selected_player.can_be_interacted_with()):
		tile.player.reset_phase()
		tile.player.on_clicked()
		#shoot_button.set_pressed_no_signal(tile.player.current_phase == PhaseType.ACTION)
		shoot_button.set_pressed_no_signal(false)
		action_button.set_pressed_no_signal(false)


func _on_player_hovered(player, is_hovered):
	if selected_player and selected_player != player:
		return
	
	if is_hovered:
		if player.current_phase == PhaseType.MOVE:
			var tiles_for_movement = calculate_tiles_for_movement(is_hovered, player)
			for tile_for_movement in tiles_for_movement:
				tile_for_movement.toggle_player_hovered(is_hovered)
		#elif player.current_phase == PhaseType.ACTION:
			#var tiles_for_action = calculate_tiles_for_action(is_hovered, player)
			#for tile_for_action in tiles_for_action:
				#tile_for_action.toggle_player_hovered(is_hovered)
	else:
		for tile in map.tiles:
			tile.toggle_player_hovered(false)
			
			#if not player.is_clicked:
				#tile.toggle_player_clicked(false)


func _on_player_clicked(player, is_clicked):
	# reset tiles for selected player if new player is selected
	if selected_player and selected_player != player and selected_player.can_be_interacted_with():
		selected_player.reset_tiles()
	
	if is_clicked:
		selected_player = player
		
		# UI
		shoot_button.set_disabled(false)
		action_button.set_disabled(selected_player.action_type == ActionType.NONE)
		#if not action_button.is_pressed() and selected_player.current_phase == PhaseType.ACTION:
			#shoot_button.set_pressed_no_signal(true)
		
		if player.current_phase == PhaseType.MOVE:
			var tiles_for_movement = calculate_tiles_for_movement(is_clicked, player)
			for tile_for_movement in tiles_for_movement:
				tile_for_movement.toggle_player_clicked(is_clicked)
		#elif player.current_phase == PhaseType.ACTION:
			#var tiles_for_action = calculate_tiles_for_action(is_clicked, player)
			#for tile_for_action in tiles_for_action:
				#tile_for_action.toggle_player_clicked(is_clicked)
	else:
		selected_player = null
		
		# UI
		shoot_button.set_disabled(true)
		action_button.set_disabled(true)
		
		for tile in map.tiles:
			#tile.toggle_player_hovered(false)
			tile.toggle_player_clicked(false)


func _on_character_action_push_back(character, origin_tile_coords):
	var hit_direction = (origin_tile_coords - character.tile.coords).sign()
	var push_direction = -1 * hit_direction
	# character can be pushed back into other character or (in)destructible tile
	var target_tiles = map.tiles.filter(func(tile): return tile.health_type != TileHealthType.DESTRUCTIBLE and tile.health_type != TileHealthType.INDESTRUCTIBLE and tile.coords == character.tile.coords + push_direction)
	if target_tiles.is_empty():
		var outside_tile_position = character.tile.position + Vector3(push_direction.y, 0, push_direction.x)
		# pushed outside of the map
		await character.move([character.tile], true, outside_tile_position)
	else:
		var target_tile = target_tiles.front()
		await character.move([target_tile], true, null)
		
		if character.is_alive and character.tile:
			if character.tile.health_type == TileHealthType.DESTROYED:
				# fell down
				character.get_killed()
			elif character.tile == target_tile and character.is_in_group('ENEMIES'):
				var enemy = character
				if enemy.planned_tile:
					# push planned tile with pushed enemy
					var planned_tiles = map.tiles.filter(func(tile): return tile.coords == enemy.planned_tile.coords + push_direction)
					if planned_tiles.is_empty():
						print('enemy ' + str(enemy.tile.coords) + ' -> planned tile cannot be pushed back')
						enemy.reset_planned_tile()
					else:
						enemy.plan_action(planned_tiles.front())
	
	recalculate_enemies_planned_actions()


func _on_character_action_pull_front(character, origin_tile_coords):
	var hit_direction = (origin_tile_coords - character.tile.coords).sign()
	var pull_direction = hit_direction
	# character can be pulled front into other character or (in)destructible tile
	var target_tiles = map.tiles.filter(func(tile): return tile.health_type != TileHealthType.DESTRUCTIBLE and tile.health_type != TileHealthType.INDESTRUCTIBLE and tile.coords == character.tile.coords + pull_direction)
	if target_tiles.is_empty():
		# pulled outside of the map - is this even possible?
		await character.move([character.tile], true, null)
	else:
		var target_tile = target_tiles.front()
		await character.move([target_tile], true, null)
		
		if character.is_alive and character.tile:
			if character.tile.health_type == TileHealthType.DESTROYED:
				# fell down
				character.get_killed()
			elif character.tile == target_tile and character.is_in_group('ENEMIES'):
				var enemy = character
				if enemy.planned_tile:
					# pull planned tile with pulled enemy
					var planned_tiles = map.tiles.filter(func(tile): return tile.coords == enemy.planned_tile.coords + pull_direction)
					if planned_tiles.is_empty():
						print('enemy ' + str(enemy.tile.coords) + ' -> planned tile cannot be pulled front')
						enemy.reset_planned_tile()
					else:
						enemy.plan_action(planned_tiles.front())
	
	recalculate_enemies_planned_actions()


func _on_character_action_miss_action(character):
	character.state_type = StateType.MISS_ACTION
	
	if character.is_in_group('ENEMIES'):
		var enemy = character
		enemy.reset_planned_tile()


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
