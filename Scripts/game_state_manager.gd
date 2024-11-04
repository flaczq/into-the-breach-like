extends Util

@export var map_scenes: Array[PackedScene] = []
@export var player_scenes: Array[PackedScene] = []
@export var enemy_scenes: Array[PackedScene] = []
@export var civilian_scenes: Array[PackedScene] = []
@export var progress_scene: PackedScene

@onready var game_info_label = $'../CanvasLayer/UI/GameInfoLabel'
@onready var debug_info_label = $'../CanvasLayer/UI/PlayerInfoContainer/DebugInfoLabel'
@onready var end_turn_button = $'../CanvasLayer/UI/PlayerInfoContainer/PlayerButtons/EndTurnButton'
@onready var shoot_button = $'../CanvasLayer/UI/PlayerInfoContainer/PlayerButtons/ShootButton'
@onready var action_button = $'../CanvasLayer/UI/PlayerInfoContainer/PlayerButtons/ActionButton'
@onready var undo_button = $'../CanvasLayer/UI/PlayerInfoContainer/PlayerButtons/UndoButton'
@onready var tile_info_label = $'../CanvasLayer/UI/TileInfoLabel'
@onready var turn_end_popup = $'../CanvasLayer/UI/TurnEndPopup'
@onready var turn_end_label = $'../CanvasLayer/UI/TurnEndPopup/TurnEndLabel'
@onready var level_end_popup = $'../CanvasLayer/UI/LevelEndPopup'
@onready var level_end_label = $'../CanvasLayer/UI/LevelEndPopup/LevelEndLabel'

# FIXME hardcoded
#const MAX_TUTORIAL_LEVELS: int = 6

var tutorial_manager_script: Node = preload('res://Scripts/tutorial_manager.gd').new()
var level_manager_script: Node = preload('res://Scripts/level_manager.gd').new()
var map: Node3D = null
var players: Array[Node3D] = []
var enemies: Array[Node3D] = []
var civilians: Array[Node3D] = []
var level_data: Dictionary = {}
var level_end_clicked: bool = false

var level: int
var max_levels: int
var current_turn: int
var points: int
var selected_player: Node3D
var undo: Dictionary


func _ready():
	level = 0
	
	# FIXME
	max_levels = 9
	points = 0
	
	level_manager_script.connect('init_enemy_event', _on_init_enemy)
	
	if Global.build_mode == Global.BuildMode.DEBUG:
		debug_info_label.show()
	else:
		debug_info_label.hide()


func progress():
	if Global.tutorial:
		init_by_level_type(LevelType.TUTORIAL)
	else:
		get_parent().toggle_visibility(false)
		
		get_tree().root.add_child(progress_scene.instantiate())


func init_by_level_type(level_type):
	# level not increased yet
	level_data = level_manager_script.generate_data(level_type, level + 1, enemy_scenes.size(), civilian_scenes.size())
	
	next_level()
	init()


func init(init_level_data = level_data):
	# already increased level
	Global.engine_mode = Global.EngineMode.GAME
	
	if init_level_data != level_data:
		level_data = init_level_data
	
	init_game_state()
	init_map()
	init_players()
	init_enemies()
	init_civilians()
	
	await show_turn_end_popup('ENEMY')
	
	start_turn()


func init_game_state():
	current_turn = 1
	selected_player = null
	undo = {}
	
	# UI
	reset_ui()
	end_turn_button.set_disabled(true)
	shoot_button.set_disabled(true)
	action_button.set_disabled(true)
	undo_button.set_disabled(true)
	turn_end_popup.hide()
	turn_end_label.text = ''
	level_end_popup.hide()
	level_end_label.text = ''
	
	Global.tutorial = (level_data.level_type == LevelType.TUTORIAL)


func init_map():
	map = map_scenes[level_data.scene].instantiate()
	add_sibling(map)
	map.spawn(level_data)
	
	for tile in map.tiles:
		tile.connect('hovered_event', _on_tile_hovered)
		tile.connect('clicked_event', _on_tile_clicked)
		tile.connect('action_cross_push_back', _on_tile_action_cross_push_back)


func init_players():
	players = []
	
	for player_scene in level_data.player_scenes:
		var player_instance = player_scenes[player_scene].instantiate()
		add_sibling(player_instance)
		if Global.tutorial:
			tutorial_manager_script.init_player(player_instance, level)
		
		#player_instance.init(current_level_player)
		var spawn_tile = map.get_spawnable_tiles(level_data.spawn_player_coords).pick_random()
		player_instance.spawn(spawn_tile)
		
		player_instance.connect('hovered_event', _on_player_hovered)
		player_instance.connect('clicked_event', _on_player_clicked)
		player_instance.connect('action_push_back', _on_character_action_push_back)
		player_instance.connect('action_pull_front', _on_character_action_pull_front)
		player_instance.connect('action_miss_action', _on_character_action_miss_action)
		player_instance.connect('action_hit_ally', _on_character_action_hit_ally)
		player_instance.connect('action_give_shield', _on_character_action_give_shield)
		player_instance.connect('action_slow_down', _on_character_action_slow_down)
		player_instance.connect('action_cross_push_back', _on_character_action_cross_push_back)
		player_instance.connect('action_indicators_cross_push_back', _on_action_indicators_cross_push_back)
		
		players.push_back(player_instance)


func init_enemies():
	enemies = []
	
	for enemy_scene in level_data.enemy_scenes:
		var spawn_tile = map.get_spawnable_tiles(level_data.spawn_enemy_coords).pick_random()
		_on_init_enemy(enemy_scene, spawn_tile)


func init_civilians():
	civilians = []
	
	for civilian_scene in level_data.civilian_scenes:
		var civilian_instance = civilian_scenes[civilian_scene].instantiate()
		add_sibling(civilian_instance)
		if Global.tutorial:
			tutorial_manager_script.init_civilian(civilian_instance, level)
		
		#civilian_instance.init(current_level_civilian)
		var spawn_tile = map.get_spawnable_tiles(level_data.spawn_civilian_coords).pick_random()
		civilian_instance.spawn(spawn_tile)
		
		civilian_instance.connect('action_push_back', _on_character_action_push_back)
		civilian_instance.connect('action_pull_front', _on_character_action_pull_front)
		civilian_instance.connect('action_miss_action', _on_character_action_miss_action)
		civilian_instance.connect('action_hit_ally', _on_character_action_hit_ally)
		civilian_instance.connect('action_give_shield', _on_character_action_give_shield)
		civilian_instance.connect('action_slow_down', _on_character_action_slow_down)
		civilian_instance.connect('action_cross_push_back', _on_character_action_cross_push_back)
		civilian_instance.connect('action_indicators_cross_push_back', _on_action_indicators_cross_push_back)
		
		civilians.push_back(civilian_instance)


func start_turn():
	###############################################
	# ┏┓┏┓┳┳┓┏┓  ┳┳┓┏┓•┳┓  ┓ ┏┓┏┓┏┓  ┏┓┏┳┓┏┓┳┓┏┳┓ #
	# ┃┓┣┫┃┃┃┣   ┃┃┃┣┫┓┃┃  ┃ ┃┃┃┃┃┃  ┗┓ ┃ ┣┫┣┫ ┃  #
	# ┗┛┛┗┛ ┗┗┛  ┛ ┗┛┗┗┛┗  ┗┛┗┛┗┛┣┛  ┗┛ ┻ ┛┗┛┗ ┻  #
	###############################################
	
	level_manager_script.plan_events(map, level_data, current_turn)
	
	# actions order: events plan > civilians > enemies move and plan > players > enemies actions > events actions
	var alive_civilians = civilians.filter(func(civilian): return civilian.is_alive)
	var alive_enemies = enemies.filter(func(enemy): return enemy.is_alive)
	var alive_players = players.filter(func(player): return player.is_alive)
	
	for civilian in alive_civilians:
		var tiles_for_movement = calculate_tiles_for_movement(true, civilian)
		if tiles_for_movement.is_empty():
			tiles_for_movement.push_back(civilian.tile)
		
		# prefer to move if possible
		var target_tile_for_movement = (tiles_for_movement[0]) if (tiles_for_movement.size() == 1) else (tiles_for_movement.filter(func(tile): return tile != civilian.tile)).pick_random()
		var tiles_path = calculate_tiles_path(civilian, target_tile_for_movement)
		await civilian.move(tiles_path)
		# recalculate_enemies_planned_actions is not necessary because civilians move before enemies plan their actions
	
	# NOT (enemy targets order: assets > civilians > players) -> all are of the same priority
	var target_tiles_for_enemy = [
		alive_civilians.map(func(alive_civilian): return alive_civilian.tile) +
		alive_players.map(func(alive_player): return alive_player.tile)
	]
	var targetable_tiles = map.get_targetable_tiles()
	if not targetable_tiles.is_empty():
		#target_tiles_for_enemy.push_front(targetable_tiles)
		target_tiles_for_enemy[0] += targetable_tiles
	
	# sort by order
	alive_enemies.sort_custom(func(e1, e2): return e1.order < e2.order)
	for enemy in alive_enemies:
		var tiles_for_movement = calculate_tiles_for_movement(true, enemy)
		tiles_for_movement.push_back(enemy.tile)
		var target_tile_for_movement = calculate_tile_for_movement_towards_characters(tiles_for_movement, enemy, target_tiles_for_enemy)
		if not target_tile_for_movement:
			target_tile_for_movement = tiles_for_movement.pick_random()
			print('enemy ' + str(enemy.tile.coords) + ' -> random move ' + str(target_tile_for_movement.coords))
		
		var tiles_path = calculate_tiles_path(enemy, target_tile_for_movement)
		await enemy.move(tiles_path)
		
		# wait for 'thinking' about action
		await get_tree().create_timer(0.3).timeout
	
		# enemy shouldn't but could have moved in front of the other enemy attack line
		recalculate_enemies_planned_actions()
		
		var tiles_for_action = calculate_tiles_for_action(true, enemy)
		if tiles_for_action.is_empty():
			print('enemy ' + str(enemy.tile.coords) + ' -> no actions available')
		else:
			var target_tile_for_action = calculate_tile_for_action_towards_characters(tiles_for_action, target_tiles_for_enemy)
			if not target_tile_for_action:
				# no friendly fire preferred
				var no_ff_tiles = tiles_for_action.filter(func(tile): return not tile.enemy)
				if no_ff_tiles.is_empty():
					target_tile_for_action = tiles_for_action.pick_random()
				else:
					target_tile_for_action = no_ff_tiles.pick_random()
				print('enemy ' + str(enemy.tile.coords) + ' -> random action ' + str(target_tile_for_action.coords))
			
			enemy.plan_action(target_tile_for_action)
	
	for player in alive_players:
		player.start_turn()
	
	# UI
	end_turn_button.set_disabled(false)
	
	await show_turn_end_popup()


func end_turn():
	# UI
	end_turn_button.set_disabled(true)
	shoot_button.set_pressed_no_signal(false)
	action_button.set_pressed_no_signal(false)
	undo_button.set_disabled(true)
	undo = {}
	
	await show_turn_end_popup('ENEMY')
	
	for player in players.filter(func(player): return player.is_alive):
		#player.reset_phase()
		player.reset_tiles()
		player.reset_states()
		player.current_phase = PhaseType.WAIT
	
	enemies.sort_custom(func(e1, e2): return e1.order < e2.order)
	for enemy in enemies:
		# enemy could have been killed by another enemy inside this loop
		if enemy.is_alive:
			await enemy.execute_planned_action()
	
	await level_manager_script.execute_events(map, level_data, current_turn)
	
	check_for_level_end()
	
	#########################################
	# ┏┓┏┓┳┳┓┏┓  ┳┳┓┏┓•┳┓  ┓ ┏┓┏┓┏┓  ┏┓┳┓┳┓ #
	# ┃┓┣┫┃┃┃┣   ┃┃┃┣┫┓┃┃  ┃ ┃┃┃┃┃┃  ┣ ┃┃┃┃ #
	# ┗┛┛┗┛ ┗┗┛  ┛ ┗┛┗┗┛┗  ┗┛┗┛┗┛┣┛  ┗┛┛┗┻┛ #
	#########################################


func next_turn():
	current_turn += 1
	
	# UI
	game_info_label.text = 'LEVEL: ' + str(level) + '\n'
	game_info_label.text += 'TURN: ' + str(current_turn) + '\n'
	game_info_label.text += 'POINTS: ' + str(points)
	
	start_turn()


func next_level():
	if map:
		map.queue_free()
		map = null
	
	for player in players:
		player.queue_free()
	
	for enemy in enemies:
		enemy.queue_free()
	
	for civilian in civilians:
		civilian.queue_free()
	
	enemies = []
	players = []
	civilians = []
	
	level += 1


func check_for_level_end(turn_ended = true):
	if enemies.filter(func(enemy): return enemy.is_alive).is_empty():
		level_won()
	elif turn_ended:
		if players.filter(func(player): return player.is_alive).is_empty():# or civilians.filter(func(civilian): return civilian.is_alive).is_empty():
			level_lost()
		elif level_data.level_type == LevelType.SURVIVE_TURNS:
			# turn not increased yet
			if current_turn >= level_data.max_turns:
				level_won()
			else:
				next_turn()
		else:
			next_turn()


func level_won():
	points += civilians.filter(func(civilian): return civilian.is_alive).size()
	
	# TODO
	if level < max_levels and not Global.editor:
		level_end_label.text = 'LEVEL WON'
		level_end_popup.show()
		#next_level()
		#init(LevelType.TUTORIAL)
	else:
		print('WINNER WINNER!!!')


func level_lost():
	if not Global.editor:
		level_end_label.text = 'LEVEL LOST'
		level_end_popup.show()
	else:
		print('LOOOOOOST!!!')
		# TODO achievements
		print('achievement unlocked: you\'re a game journalist now')


func show_turn_end_popup(whose_turn = 'PLAYER'):
	pass
	## FIXME hardcoded
	#turn_end_label.text = whose_turn + ' TURN'
	#turn_end_popup.color = Color(0, 0, 0, 0.5)
	#turn_end_popup.show()
	#
	#await get_tree().create_timer(1.0).timeout
	#
	#var turn_end_tween = create_tween()
	#turn_end_tween.tween_property(turn_end_popup, 'color:a', 0, 1.0).from(0.5)
	#await turn_end_tween.finished
	#
	#turn_end_label.text = ''
	#turn_end_popup.hide()
	#
	#if whose_turn == 'ENEMY':
		#await get_tree().create_timer(0.5).timeout


func reset_ui():
	game_info_label.text = 'LEVEL: ' + str(level) + '\n'
	game_info_label.text += 'TURN: ' + str(current_turn) + '\n'
	game_info_label.text += 'POINTS: ' + str(points)
	debug_info_label.text = ''
	tile_info_label.text = ''


func calculate_tiles_for_movement(active, character):
	var tiles_for_movement = []
	
	if active:
		#tiles_for_movement.push_back(character.tile)
		var i = 1
		
		# don't even ask how this works
		var origin_tiles = [character.tile]
		var move_distance = (1) if (character.state_type == StateType.SLOW_DOWN) else (character.move_distance)
		
		while i <= move_distance:
			var temp_origin_tiles = []
			
			for origin_tile in origin_tiles:
				# can't walk into water/lava, can only be pushed there
				for tile in map.tiles.filter(func(tile): return tile.health_type != TileHealthType.INDESTRUCTIBLE_WALKABLE):
					# characters can move through other characters of the same type
					var occupied_by_characters = (not character.is_in_group('PLAYERS') and tile.player) or (not character.is_in_group('ENEMIES') and tile.enemy) or (not character.is_in_group('CIVILIANS') and tile.civilian)
					if not occupied_by_characters and not tiles_for_movement.has(tile):
						if is_tile_adjacent(tile, origin_tile):
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


func is_tile_adjacent(tile, origin_tile, check_for_movement = true):
	if check_for_movement and (tile.health_type == TileHealthType.DESTROYED or tile.health_type == TileHealthType.DESTRUCTIBLE_HEALTHY or tile.health_type == TileHealthType.DESTRUCTIBLE_DAMAGED or tile.health_type == TileHealthType.INDESTRUCTIBLE):
		return false
	
	return is_tile_adjacent_by_coords(tile.coords, origin_tile.coords)


func calculate_tiles_path(character, target_tile):
	var map_dimension = map.get_side_dimension()
	var astar_grid_map = AStarGrid2D.new()
	astar_grid_map.region = Rect2i(1, 1, map_dimension, map_dimension)
	astar_grid_map.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid_map.update()
	
	for tile in map.tiles:
		var occupied_by_health_type = (tile.health_type == TileHealthType.DESTROYED or tile.health_type == TileHealthType.DESTRUCTIBLE_HEALTHY or tile.health_type == TileHealthType.DESTRUCTIBLE_DAMAGED or tile.health_type == TileHealthType.INDESTRUCTIBLE)
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
				if (tile.coords.x == origin_tile.coords.x and absi(tile.coords.y - origin_tile.coords.y) >= character.action_min_distance and absi(tile.coords.y - origin_tile.coords.y) <= character.action_max_distance) \
					or (tile.coords.y == origin_tile.coords.y and absi(tile.coords.x - origin_tile.coords.x) >= character.action_min_distance and absi(tile.coords.x - origin_tile.coords.x) <= character.action_max_distance):
					# include all tiles in path
					if character.is_in_group('PLAYERS'):
						push_unique_to_array(tiles_for_action, tile)
					else:
						var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(character, character.tile.coords, tile.coords)
						if not first_occupied_tile_in_line:
							first_occupied_tile_in_line = tile
						
						push_unique_to_array(tiles_for_action, first_occupied_tile_in_line)
		elif character.action_direction == ActionDirection.VERTICAL_LINE or character.action_direction == ActionDirection.VERTICAL_DOT:
			var min_range = maxi(1, character.action_min_distance)
			var max_range = mini(map.get_side_dimension(), character.action_max_distance)
			for i in range(min_range, max_range + 1):
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
			var occupied_tiles = tiles_for_action.filter(func(tile): return tile.health_type == TileHealthType.DESTRUCTIBLE_HEALTHY or tile.health_type == TileHealthType.DESTRUCTIBLE_DAMAGED or tile.health_type == TileHealthType.INDESTRUCTIBLE or tile.get_character())
			if not occupied_tiles.is_empty():
				for occupied_tile in occupied_tiles:
					var origin_to_target_sign = (character.tile.coords - occupied_tile.coords).sign()
					var hit_direction = get_hit_direction(origin_to_target_sign)
					if hit_direction == HitDirection.DOWN_LEFT:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.y != occupied_tile.coords.y or tile.coords.x <= occupied_tile.coords.x)
					elif hit_direction == HitDirection.UP_RIGHT:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.y != occupied_tile.coords.y or tile.coords.x >= occupied_tile.coords.x)
					elif hit_direction == HitDirection.RIGHT_DOWN:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.x != occupied_tile.coords.x or tile.coords.y <= occupied_tile.coords.y)
					elif hit_direction == HitDirection.LEFT_UP:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.x != occupied_tile.coords.x or tile.coords.y >= occupied_tile.coords.y)
					elif hit_direction == HitDirection.DOWN:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.x - tile.coords.y != occupied_tile.coords.x - occupied_tile.coords.y or tile.coords.x <= occupied_tile.coords.x)
					elif hit_direction == HitDirection.UP:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.x - tile.coords.y != occupied_tile.coords.x - occupied_tile.coords.y or tile.coords.x >= occupied_tile.coords.x)
					elif hit_direction == HitDirection.RIGHT:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.x - tile.coords.y >= occupied_tile.coords.x - occupied_tile.coords.y)
					elif hit_direction == HitDirection.LEFT:
						tiles_for_action = tiles_for_action.filter(func(tile): return tile.coords.x - tile.coords.y <= occupied_tile.coords.x - occupied_tile.coords.y)
	else:
		tiles_for_action = map.tiles
	
	return tiles_for_action


func calculate_tile_for_movement_towards_characters(tiles_for_movement, origin_character, different_target_tiles):
	for target_tiles in different_target_tiles:
		var valid_tiles_for_movement = []
		var target_tile_for_movement = null
		
		# make it random
		tiles_for_movement.shuffle()
		
		if tiles_for_movement.has(origin_character.tile):
			# prefer to move (origin character tile at the last position)
			tiles_for_movement.erase(origin_character.tile)
			tiles_for_movement.push_back(origin_character.tile)
		
		for tile_for_movement in tiles_for_movement:
			if origin_character.action_direction == ActionDirection.HORIZONTAL_LINE or origin_character.action_direction == ActionDirection.HORIZONTAL_DOT:
				valid_tiles_for_movement = target_tiles.filter(func(target_tile): return \
					(target_tile.coords.x == tile_for_movement.coords.x and absi(target_tile.coords.y - tile_for_movement.coords.y) >= origin_character.action_min_distance and absi(target_tile.coords.y - tile_for_movement.coords.y) <= origin_character.action_max_distance) \
					or (target_tile.coords.y == tile_for_movement.coords.y and absi(target_tile.coords.x - tile_for_movement.coords.x) >= origin_character.action_min_distance and absi(target_tile.coords.x - tile_for_movement.coords.x) <= origin_character.action_max_distance))
				if not valid_tiles_for_movement.is_empty():
					target_tile_for_movement = tile_for_movement
			elif origin_character.action_direction == ActionDirection.VERTICAL_LINE or origin_character.action_direction == ActionDirection.VERTICAL_DOT:
				var min_range = maxi(1, origin_character.action_min_distance)
				var max_range = mini(map.get_side_dimension(), origin_character.action_max_distance)
				for i in range(min_range, max_range + 1):
					var valid_tiles = target_tiles.filter(func(target_tile): return abs(target_tile.coords - tile_for_movement.coords) == Vector2i(i, i))
					if not valid_tiles.is_empty():
						valid_tiles_for_movement.append_array(valid_tiles)
			
				if not valid_tiles_for_movement.is_empty():
					target_tile_for_movement = tile_for_movement
			
			# exclude tiles behind occupied tiles
			if target_tile_for_movement and (origin_character.action_direction == ActionDirection.HORIZONTAL_LINE or origin_character.action_direction == ActionDirection.VERTICAL_LINE):
				if valid_tiles_for_movement.all(func(target_tile): return target_tile != calculate_first_occupied_tile_for_action_direction_line(origin_character, target_tile_for_movement.coords, target_tile.coords)):
					valid_tiles_for_movement = []
					target_tile_for_movement = null
			
			if target_tile_for_movement:
				# exlude tiles in front of the other enemy attack line
				if origin_character.is_in_group('ENEMIES'):
					for other_enemy in enemies.filter(func(enemy): return enemy != origin_character and enemy.planned_tile and (enemy.action_direction == ActionDirection.HORIZONTAL_LINE or enemy.action_direction == ActionDirection.VERTICAL_LINE)):
						var other_enemy_to_planned_sign = (other_enemy.tile.coords - other_enemy.planned_tile.coords).sign()
						var target_tile_to_other_enemy_planned_sign = (target_tile_for_movement.coords - other_enemy.planned_tile.coords).sign()
						var target_tile_to_other_enemy_sign = (target_tile_for_movement.coords - other_enemy.tile.coords).sign()
						if get_hit_direction(other_enemy_to_planned_sign) == get_hit_direction(target_tile_to_other_enemy_planned_sign) and get_hit_direction(target_tile_to_other_enemy_planned_sign) != get_hit_direction(target_tile_to_other_enemy_sign):
							valid_tiles_for_movement = []
							target_tile_for_movement = null
							break;
				
				if target_tile_for_movement:
					return target_tile_for_movement
	
	return null


func calculate_tile_for_action_towards_characters(tiles_for_action, different_target_tiles):
	for target_tiles in different_target_tiles:
		# make it random
		tiles_for_action.shuffle()
		
		for tile_for_action in tiles_for_action:
			if target_tiles.any(func(target_tile): return target_tile.coords == tile_for_action.coords):
				return tile_for_action
	
	return null


func calculate_first_occupied_tile_for_action_direction_line(origin_character, origin_tile_coords, target_tile_coords):
	if origin_character.action_direction == ActionDirection.HORIZONTAL_LINE or origin_character.action_direction == ActionDirection.VERTICAL_LINE:
		var hit_direction = (origin_tile_coords - target_tile_coords).sign()
		var tiles_in_line = []
		var min_range = maxi(1, origin_character.action_min_distance)
		var max_range = mini(map.get_side_dimension(), origin_character.action_max_distance)
		for i in range(min_range, max_range + 1):
			var current_tiles_in_line = map.tiles.filter(func(tile): return tile.coords == origin_tile_coords - hit_direction * i)
			if not current_tiles_in_line.is_empty():
				push_unique_to_array(tiles_in_line, current_tiles_in_line.front())
		
		var occupied_tiles_in_line = tiles_in_line.filter(func(tile): return (tile.health_type == TileHealthType.DESTRUCTIBLE_HEALTHY or tile.health_type == TileHealthType.DESTRUCTIBLE_DAMAGED or tile.health_type == TileHealthType.INDESTRUCTIBLE or (tile.player and not tile.player.is_ghost) or tile.ghost or tile.enemy or tile.civilian) and tile != origin_character.tile)
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
		else:
			# just to be sure and refresh arrows, indicators, etc.
			enemy.plan_action(enemy.planned_tile)
			
		# planned tile could've lost 'is_planned_enemy_action' true flag
		if not enemy.planned_tile.is_planned_enemy_action:
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


func _on_init_enemy(enemy_scene, spawn_tile):
	var enemy_instance = enemy_scenes[enemy_scene].instantiate()
	if Global.tutorial:
		tutorial_manager_script.init_enemy(enemy_instance, level)
	
	add_sibling(enemy_instance)
	
	# find max order
	var enemies_orders = enemies.map(func(enemy): return enemy.order)
	var max_order = (0) if (enemies_orders.is_empty()) else (enemies_orders.max())
	enemy_instance.spawn(spawn_tile, max_order + 1)
	
	enemy_instance.connect('action_push_back', _on_character_action_push_back)
	enemy_instance.connect('action_pull_front', _on_character_action_pull_front)
	enemy_instance.connect('action_miss_action', _on_character_action_miss_action)
	enemy_instance.connect('action_hit_ally', _on_character_action_hit_ally)
	enemy_instance.connect('action_give_shield', _on_character_action_give_shield)
	enemy_instance.connect('action_slow_down', _on_character_action_slow_down)
	enemy_instance.connect('action_cross_push_back', _on_character_action_cross_push_back)
	enemy_instance.connect('action_indicators_cross_push_back', _on_action_indicators_cross_push_back)
	enemy_instance.connect('recalculate_order_event', _on_recalculate_order_event)
	
	enemies.push_back(enemy_instance)


func _on_tile_hovered(tile, is_hovered):
	# reset all kinds of arrows, indicators, outlines, ...
	for current_player in players:
		current_player.is_ghost = false
		current_player.reset_health_bar()
		
		if current_player != selected_player:
			current_player.toggle_outline(false)
			current_player.toggle_health_bar(false)
	
	for current_tile in map.tiles:
		current_tile.ghost = null
		current_tile.toggle_shader(false)
		
		if not is_hovered:
			current_tile.toggle_asset_outline(false)
		
		# reset other tiles
		if current_tile != tile:
			current_tile.is_hovered = false
			current_tile.reset_tile_models()
	
	for current_enemy in enemies:
		current_enemy.toggle_arrow_highlight(false)
		current_enemy.toggle_outline(false)
		current_enemy.toggle_health_bar(false)
		current_enemy.reset_health_bar()
	
	for current_civilian in civilians:
		current_civilian.toggle_outline(false)
		current_civilian.toggle_health_bar(false)
		current_civilian.reset_health_bar()
	
	var character = tile.get_character()
	
	# UI
	if is_hovered:
		# ┏┳┓•┓ ┏┓  •┳┓┏┓┏┓
		#  ┃ ┓┃ ┣   ┓┃┃┣ ┃┃
		#  ┻ ┗┗┛┗┛  ┗┛┗┻ ┗┛
		
		# DEBUG
		debug_info_label.text = 'POSITION: ' + str(tile.position) + '\n'
		debug_info_label.text += 'COORDS: ' + str(tile.coords) + '\n'
		debug_info_label.text += 'HEALTH TYPE: ' + str(TileHealthType.keys()[tile.health_type]) + '\n\n'
		debug_info_label.text += 'TILE TYPE: ' + str(TileType.keys()[tile.tile_type]) + '\n'
		if character:
			debug_info_label.text += '\n\n' + character.model_name + '\n'
			debug_info_label.text += tr('INFO_HEALTH') + ': ' + str(character.health) + '/' + str(character.max_health) + '\n'
			debug_info_label.text += 'ACTION TYPE: ' + str(ActionType.keys()[character.action_type]) + '\n'
			debug_info_label.text += 'ACTION DIRECTION: ' + str(ActionDirection.keys()[character.action_direction]) + '\n'
			debug_info_label.text += 'ACTION DISTANCE: ' + str(character.action_min_distance) + '-' + str(character.action_max_distance) + '\n'
			debug_info_label.text += 'MOVE DISTANCE: ' + str(character.move_distance) + '\n'
			debug_info_label.text += 'STATE TYPE: ' + str(StateType.keys()[character.state_type])
		if tile.models.get('event_asset'):
			if tile.models.event_asset.is_in_group('MORE_ENEMIES_INDICATORS'):
				debug_info_label.text += '\n\n' + 'TILE LEVEL EVENT: ' + str(LevelEvent.keys()[LevelEvent.MORE_ENEMIES]) + '\n'
			elif tile.models.event_asset.is_in_group('MISSLES_INDICATORS'):
				debug_info_label.text += '\n\n' + 'TILE LEVEL EVENT: ' + str(LevelEvent.keys()[LevelEvent.FALLING_MISSLE]) + '\n'
			elif tile.models.event_asset.is_in_group('ROCKS_INDICATORS'):
				debug_info_label.text += '\n\n' + 'TILE LEVEL EVENT: ' + str(LevelEvent.keys()[LevelEvent.FALLING_ROCK]) + '\n'
		
		if tile.info and not tile.info.is_empty():
			debug_info_label.text += '\n\n' + tile.info
		
		# tile and character hover info
		# TODO
		tile_info_label.text += '[TILE ICON] ' + tr('TILE_TYPE_' + str(TileType.keys()[tile.tile_type])) + '\n'
		if character:
			tile_info_label.text += '[ACTION ICON] ' + tr('ACTION_' + str(ActionType.keys()[character.action_type])) + '\n'
			tile_info_label.text += '[MOVE ICON] ' + tr('MOVE_' + str(character.move_distance)) + '\n'
			if character.state_type != StateType.NONE:
				tile_info_label.text += '[STATE ICON] ' + tr('STATE_TYPE_' + str(StateType.keys()[character.state_type]))
	else:
		debug_info_label.text = ''
		tile_info_label.text = ''
	
	if is_hovered:
		# show health bar for hovered character
		if character:
			character.toggle_health_bar(true)
		
		# outline hovered enemy and highlight his attack arrows
		if tile.enemy:
			#tile.enemy.toggle_outline(true)
			
			if tile.enemy.planned_tile:
				var is_selected_player_action = selected_player and selected_player.current_phase == PhaseType.ACTION and action_button.is_pressed()
				if not is_selected_player_action:
					tile.enemy.toggle_arrow_highlight(true)
					tile.enemy.planned_tile.toggle_asset_outline(true)
					
					# highlight tile itself if it's empty
					if not tile.enemy.planned_tile.is_occupied():
						tile.enemy.planned_tile.toggle_shader(true)
					
					# show outline with predicted health for enemy targets
					if tile.enemy.action_type == ActionType.CROSS_PUSH_BACK:
						# only for target tile
						tile.enemy.show_outline_with_predicted_health(tile.enemy.planned_tile, map.tiles, ActionType.NONE)
						
						# only for tiles to be cross pushed back
						for current_tile in map.tiles.filter(func(current_tile): return is_tile_adjacent_by_coords(tile.enemy.planned_tile.coords, current_tile.coords)):
							# show outline with predicted health for enemy cross pushed targets
							tile.enemy.show_outline_with_predicted_health(current_tile, map.tiles, ActionType.CROSS_PUSH_BACK, tile.enemy.planned_tile, tile.enemy.action_damage)
					else:
						tile.enemy.show_outline_with_predicted_health(tile.enemy.planned_tile, map.tiles, tile.enemy.action_type)
		
		# highlight attack arrows of hovered planned target
		if tile.is_planned_enemy_action:
			#tile.toggle_shader(true)
			#tile.toggle_asset_outline(true)
			
			var is_selected_player_action = selected_player and selected_player.current_phase == PhaseType.ACTION and action_button.is_pressed()
			if not is_selected_player_action:
				# find enemy whose planned tile is hovered
				for current_enemy in enemies.filter(func(enemy): return enemy.planned_tile == tile):
					current_enemy.toggle_outline(true)
					current_enemy.toggle_health_bar(true)
					#current_enemy.toggle_arrow_highlight(true)
	
	# highlight tiles while player is clicked
	if selected_player and selected_player.tile != tile and tile.is_player_clicked:
		if selected_player.current_phase == PhaseType.MOVE:
			#for other_tile in map.tiles.filter(func(current_tile): return current_tile != tile):
				#other_tile.reset_tile_models()
			
			if is_hovered:
				var tiles_path = calculate_tiles_path(selected_player, tile)
				for next_tile in tiles_path:
					next_tile.on_mouse_entered()
				
				selected_player.look_at_y(tile)
				selected_player.is_ghost = true
				tile.ghost = selected_player
			
			recalculate_enemies_planned_actions()
		elif selected_player.current_phase == PhaseType.ACTION:
			if is_hovered:
				var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(selected_player, selected_player.tile.coords, tile.coords)
				if first_occupied_tile_in_line and first_occupied_tile_in_line != tile:
					tile.is_hovered = false
					tile.reset_tile_models()
				
					first_occupied_tile_in_line.is_hovered = true
					first_occupied_tile_in_line.reset_tile_models()
				else:
					first_occupied_tile_in_line = tile
				
				selected_player.look_at_y(first_occupied_tile_in_line)
				selected_player.spawn_arrow(first_occupied_tile_in_line)
				selected_player.spawn_action_indicators(first_occupied_tile_in_line)
				
				# highlight tile itself if it's empty
				if not first_occupied_tile_in_line.is_occupied():
					first_occupied_tile_in_line.toggle_shader(true)
				
				# show outline with predicted health for player targets
				if selected_player.action_type == ActionType.CROSS_PUSH_BACK:
					# only for target tile
					selected_player.show_outline_with_predicted_health(first_occupied_tile_in_line, map.tiles, ActionType.NONE)
					
					# only for tiles to be cross pushed back
					for current_tile in map.tiles.filter(func(current_tile): return is_tile_adjacent_by_coords(first_occupied_tile_in_line.coords, current_tile.coords)):
						selected_player.show_outline_with_predicted_health(current_tile, map.tiles, ActionType.CROSS_PUSH_BACK, first_occupied_tile_in_line, selected_player.action_damage)
				else:
					selected_player.show_outline_with_predicted_health(first_occupied_tile_in_line, map.tiles, selected_player.action_type)
			else:
				selected_player.clear_arrows()
				selected_player.clear_action_indicators()


func _on_tile_clicked(tile):
	for current_player in players:
		current_player.is_ghost = false
	
	for current_tile in map.tiles:
		current_tile.ghost = null
	
	recalculate_enemies_planned_actions()
	
	# highlighted tile is clicked while player is selected
	if selected_player and selected_player.tile != tile and tile.is_player_clicked:
		if selected_player.current_phase == PhaseType.MOVE:
			# remember player's last tile
			undo[selected_player.get_instance_id()] = selected_player.tile
			undo_button.set_disabled(false)
			
			var tiles_path = calculate_tiles_path(selected_player, tile)
			await selected_player.move(tiles_path, false)
			
			recalculate_enemies_planned_actions()
		elif selected_player.current_phase == PhaseType.ACTION:
			selected_player.clear_arrows()
			selected_player.clear_action_indicators()
		
			var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(selected_player, selected_player.tile.coords, tile.coords)
			if not first_occupied_tile_in_line:
				first_occupied_tile_in_line = tile
			
			if action_button.is_pressed():
				await selected_player.execute_action(first_occupied_tile_in_line)
			else:
				await selected_player.shoot(first_occupied_tile_in_line)
			
			# reset undo when action was executed
			undo = {}
			undo_button.set_disabled(true)
			
			check_for_level_end(false)
	# other player or selected player is clicked
	elif tile.player and (not selected_player or selected_player.tile == tile or selected_player.can_be_interacted_with()):
		tile.player.reset_phase()
		tile.player.on_clicked()
		#shoot_button.set_pressed_no_signal(tile.player.current_phase == PhaseType.ACTION)
		shoot_button.set_pressed_no_signal(false)
		action_button.set_pressed_no_signal(false)


func _on_tile_action_cross_push_back(target_tile_coords, action_damage, origin_tile_coords):
	var tiles_to_be_pushed = []
	for tile in map.tiles:
		if is_tile_adjacent_by_coords(target_tile_coords, tile.coords):
			tiles_to_be_pushed.push_back(tile)
		
		if tiles_to_be_pushed.size() == 4:
			break;
	
	var i = 0
	for tile_to_be_pushed in tiles_to_be_pushed:
		i += 1
		if i < tiles_to_be_pushed.size():
			tile_to_be_pushed.get_shot(action_damage, ActionType.PUSH_BACK, 0, target_tile_coords)
		else:
			# does this even work if it's called from signal? i don't think so...
			await tile_to_be_pushed.get_shot(action_damage, ActionType.PUSH_BACK, 0, target_tile_coords)


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
		selected_player.toggle_health_bar(true)
		
		# UI
		shoot_button.set_disabled(false)
		action_button.set_disabled(false)
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
		selected_player.toggle_health_bar(false)
		selected_player = null
		
		# UI
		shoot_button.set_disabled(true)
		action_button.set_disabled(true)
		
		for tile in map.tiles:
			#tile.toggle_player_hovered(false)
			tile.toggle_player_clicked(false)
	
	player.tile.on_mouse_entered()


func _on_character_action_push_back(target_character, action_damage, origin_tile_coords):
	var hit_direction = (origin_tile_coords - target_character.tile.coords).sign()
	var push_direction = -1 * hit_direction
	# find tile pushed into
	var pushed_into_tiles = map.tiles.filter(func(tile): return tile.coords == target_character.tile.coords + push_direction)
	if pushed_into_tiles.is_empty():
		var outside_tile_position = target_character.tile.position + Vector3(push_direction.y, 0, push_direction.x)
		# pushed outside of the map
		await target_character.move([target_character.tile], true, outside_tile_position)
	else:
		var pushed_into_tile = pushed_into_tiles.front()
		await target_character.move([pushed_into_tile], true)
		
		if target_character.is_alive and target_character.tile:
			if target_character.tile.health_type == TileHealthType.DESTROYED:
				# fell down
				await target_character.get_killed()
			elif target_character.tile.health_type == TileHealthType.INDESTRUCTIBLE_WALKABLE:
				target_character.state_type = StateType.SLOW_DOWN
			elif target_character.tile == pushed_into_tile and target_character.is_in_group('ENEMIES'):
				# enemy actually moved
				var enemy = target_character
				if enemy.planned_tile:
					# push planned tile with pushed enemy
					var planned_tiles = map.tiles.filter(func(tile): return tile.coords == enemy.planned_tile.coords + push_direction)
					if planned_tiles.is_empty():
						print('enemy ' + str(enemy.tile.coords) + ' -> planned tile cannot be pushed back')
						enemy.reset_planned_tile()
					else:
						enemy.plan_action(planned_tiles.front())
	
	recalculate_enemies_planned_actions()


func _on_character_action_pull_front(target_character, action_damage, origin_tile_coords):
	var hit_direction = (origin_tile_coords - target_character.tile.coords).sign()
	var pull_direction = hit_direction
	# find tile pulled into
	var pulled_into_tiles = map.tiles.filter(func(tile): return tile.coords == target_character.tile.coords + pull_direction)
	if pulled_into_tiles.is_empty():
		var outside_tile_position = target_character.tile.position + Vector3(pull_direction.y, 0, pull_direction.x)
		# pulled outside of the map - is this even possible?
		await target_character.move([target_character.tile], true, outside_tile_position)
	else:
		var pulled_into_tile = pulled_into_tiles.front()
		await target_character.move([pulled_into_tile], true)
		
		if target_character.is_alive and target_character.tile:
			if target_character.tile.health_type == TileHealthType.DESTROYED:
				# fell down
				await target_character.get_killed()
			elif target_character.tile.health_type == TileHealthType.INDESTRUCTIBLE_WALKABLE:
				target_character.state_type = StateType.SLOW_DOWN
			elif target_character.tile == pulled_into_tile and target_character.is_in_group('ENEMIES'):
				# enemy actually moved
				var enemy = target_character
				if enemy.planned_tile:
					# pull planned tile with pulled enemy
					var planned_tiles = map.tiles.filter(func(tile): return tile.coords == enemy.planned_tile.coords + pull_direction)
					if planned_tiles.is_empty():
						print('enemy ' + str(enemy.tile.coords) + ' -> planned tile cannot be pulled front')
						enemy.reset_planned_tile()
					else:
						enemy.plan_action(planned_tiles.front())
	
	recalculate_enemies_planned_actions()


func _on_character_action_miss_action(target_character):
	target_character.state_type = StateType.MISS_ACTION
	
	if target_character.is_in_group('ENEMIES'):
		var enemy = target_character
		enemy.reset_planned_tile()


func _on_character_action_hit_ally(target_character):
	target_character.state_type = StateType.HIT_ALLY


func _on_character_action_give_shield(target_character):
	target_character.state_type = StateType.GIVE_SHIELD


func _on_character_action_slow_down(target_character):
	target_character.state_type = StateType.SLOW_DOWN


func _on_character_action_cross_push_back(target_character, action_damage, origin_tile_coords):
	# does this even work if it's called from signal? i don't think so...
	await _on_tile_action_cross_push_back(target_character.tile.coords, action_damage, origin_tile_coords)


func _on_action_indicators_cross_push_back(target_character, origin_tile, first_origin_position):
	for tile in map.tiles.filter(func(tile): return is_tile_adjacent_by_coords(origin_tile.coords, tile.coords)):
		target_character.spawn_action_indicators(tile, origin_tile, first_origin_position, ActionType.PUSH_BACK)


func _on_recalculate_order_event():
	var order = 1
	enemies.sort_custom(func(e1, e2): return e1.order < e2.order)
	for enemy in enemies:
		enemy.order = order


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


func _on_undo_button_pressed():
	if not undo.is_empty():
		var last_undo_player_instance_id = undo.keys().back()
		var last_undo_player = players.filter(func(player): return player.get_instance_id() == last_undo_player_instance_id).front()
		var last_undo_tile = undo[last_undo_player_instance_id]
		last_undo_player.position = last_undo_tile.position
		last_undo_player.tile.set_player(null)
		last_undo_player.tile = last_undo_tile
		last_undo_tile.set_player(last_undo_player)
		
		undo.erase(last_undo_player_instance_id)
		if undo.is_empty():
			undo_button.set_disabled(true)
		
		last_undo_player.start_turn()
		
		recalculate_enemies_planned_actions()


func _on_level_end_popup_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if level_end_clicked:
			return
		
		level_end_clicked = true
		
		for player in players:
			var flying_tile_tween = create_tween()
			flying_tile_tween.tween_property(player, 'position:y', 6, 0.5)
			await flying_tile_tween.finished
	
		for enemy in enemies:
			var flying_tile_tween = create_tween()
			flying_tile_tween.tween_property(enemy, 'position:y', 6, 0.5)
			await flying_tile_tween.finished
		
		for civilian in civilians:
			var flying_tile_tween = create_tween()
			flying_tile_tween.tween_property(civilian, 'position:y', 6, 0.5)
			await flying_tile_tween.finished
		
		for tile in map.tiles:
			var flying_tile_tween = create_tween()
			flying_tile_tween.tween_property(tile, 'position:y', 6, 0.2)
			await flying_tile_tween.finished
		
		level_end_popup.hide()
		level_end_label.text = ''
		
		progress()
		
		level_end_clicked = false
