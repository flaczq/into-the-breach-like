extends Util

class_name GameStateManager

@export var map_scenes: Array[PackedScene] = []
@export var player_scenes: Array[PackedScene] = []
@export var enemy_scenes: Array[PackedScene] = []
@export var civilian_scenes: Array[PackedScene] = []
@export var progress_scene: PackedScene
@export var player_container_scene: PackedScene

@onready var end_turn_texture_button = $'../CanvasLayer/PanelLeftContainer/LeftMarginContainer/LeftContainer/LeftTopContainer/EndTurnTextureButton'
@onready var action_first_texture_button = $'../CanvasLayer/PanelLeftContainer/LeftMarginContainer/LeftContainer/LeftTopContainer/ActionFirstTextureButton'
@onready var undo_texture_button = $'../CanvasLayer/PanelLeftContainer/LeftMarginContainer/LeftContainer/LeftTopContainer/UndoTextureButton'
@onready var game_info_label = $'../CanvasLayer/PanelLeftContainer/LeftMarginContainer/LeftContainer/LeftCenterContainer/GameInfoLabel'
@onready var objectives_label = $'../CanvasLayer/PanelLeftContainer/LeftMarginContainer/LeftContainer/LeftCenterContainer/ObjectivesLabel'
@onready var players_grid_container = $'../CanvasLayer/PanelLeftContainer/LeftMarginContainer/LeftContainer/LeftBottomContainer/PlayersGridContainer'
@onready var tile_info_label = $'../CanvasLayer/PanelLeftContainer/LeftMarginContainer/LeftContainer/LeftBottomContainer/TileInfoLabel'
@onready var debug_info_label = $'../CanvasLayer/PanelRightContainer/RightMarginContainer/RightContainer/DebugInfoLabel'
@onready var panel_full_screen_container = $'../CanvasLayer/PanelFullScreenContainer'
@onready var turn_end_texture_rect = $'../CanvasLayer/PanelFullScreenContainer/TurnEndTextureRect'
@onready var turn_end_label = $'../CanvasLayer/PanelFullScreenContainer/TurnEndTextureRect/TurnEndLabel'
@onready var level_end_popup = $'../CanvasLayer/PanelFullScreenContainer/LevelEndPopup'
@onready var level_end_label = $'../CanvasLayer/PanelFullScreenContainer/LevelEndPopup/LevelEndLabel'

# FIXME hardcoded
#const MAX_TUTORIAL_LEVELS: int = 6

var tutorial_manager_script: TutorialManager = preload('res://Scripts/tutorial_manager.gd').new()
var level_manager_script: LevelManager = preload('res://Scripts/level_manager.gd').new()

var map: Map = null
var players: Array[Player] = []
var enemies: Array[Enemy] = []
var civilians: Array[Civilian] = []
var level_data: Dictionary = {}
var level_end_clicked: bool = false

var level: int
var max_levels: int
var current_turn: int
var enemies_killed: int
var selected_player: Player
var undo: Dictionary


func _ready() -> void:
	level = 0
	# FIXME
	max_levels = 9
	
	level_manager_script.connect('init_enemy_event', _on_init_enemy)
	
	if Global.build_mode == Global.BuildMode.DEBUG:
		debug_info_label.show()
	else:
		debug_info_label.hide()


func progress() -> void:
	if Global.tutorial:
		init_by_level_type(LevelType.TUTORIAL)
	else:
		get_parent().toggle_visibility(false)
		
		add_sibling(progress_scene.instantiate())


func init_by_level_type(level_type: LevelType) -> void:
	# level not increased yet
	level_data = level_manager_script.generate_data(level_type, level + 1, enemy_scenes.size(), civilian_scenes.size())
	
	next_level()
	init()


func init(init_level_data: Dictionary = level_data) -> void:
	# already increased level
	Global.engine_mode = Global.EngineMode.GAME
	
	if init_level_data != level_data:
		level_data = init_level_data
	
	init_game_state()
	init_map()
	init_players()
	init_enemies()
	init_civilians()
	init_ui()
	
	await show_turn_end_texture_rect('ENEMY')
	
	start_turn()


func init_game_state() -> void:
	current_turn = 1
	enemies_killed = 0
	selected_player = null
	undo = {}
	
	# UI
	reset_ui()
	# FIXME proper disabled icons
	on_button_disabled(end_turn_texture_button, true)
	on_button_disabled(action_first_texture_button, true)
	on_button_disabled(undo_texture_button, true)
	panel_full_screen_container.hide()
	turn_end_texture_rect.hide()
	turn_end_label.text = ''
	level_end_popup.hide()
	level_end_label.text = ''
	
	Global.tutorial = (level_data.level_type == LevelType.TUTORIAL)


func init_map() -> void:
	assert(level_data.has('scene'), 'Set scene for level_data')
	map = map_scenes[level_data.scene].instantiate()
	add_sibling(map)
	map.spawn(level_data)
	
	for tile in map.tiles:
		tile.connect('hovered_event', _on_tile_hovered)
		tile.connect('clicked_event', _on_tile_clicked)
		tile.connect('action_cross_push_back', _on_tile_action_cross_push_back)


func init_players() -> void:
	assert(level_data.has('player_scenes'), 'Set player_scenes for level_data')
	assert(level_data.has('spawn_player_coords'), 'Set spawn_player_coords for level_data')
	players = []
	
	for player_scene in level_data.player_scenes:
		var player_instance = player_scenes[player_scene].instantiate() as Player
		add_sibling(player_instance)
		if Global.tutorial:
			tutorial_manager_script.init_player(player_instance, level)
		
		#player_instance.init(current_level_player)
		var spawn_tile = map.get_spawnable_tiles(level_data.spawn_player_coords).pick_random()
		if not spawn_tile:
			print('no tiles to spawn for spawn player coords: ' + str(level_data.spawn_player_coords))
			return
		
		player_instance.spawn(spawn_tile)
		
		player_instance.connect('hovered_event', _on_player_hovered)
		player_instance.connect('clicked_event', _on_player_clicked)
		player_instance.connect('health_changed_event', _on_player_health_changed)
		player_instance.connect('action_push_back', _on_character_action_push_back)
		player_instance.connect('action_pull_front', _on_character_action_pull_front)
		player_instance.connect('action_hit_ally', _on_character_action_hit_ally)
		player_instance.connect('action_give_shield', _on_character_action_give_shield)
		player_instance.connect('action_slow_down', _on_character_action_slow_down)
		player_instance.connect('action_cross_push_back', _on_character_action_cross_push_back)
		player_instance.connect('action_indicators_cross_push_back', _on_action_indicators_cross_push_back)
		player_instance.connect('collectable_picked_event', _on_collectable_picked_event)
		
		players.push_back(player_instance)


func init_enemies() -> void:
	assert(level_data.has('enemy_scenes'), 'Set enemy_scenes for level_data')
	assert(level_data.has('spawn_enemy_coords'), 'Set spawn_enemy_coords for level_data')
	enemies = []
	
	for enemy_scene in level_data.enemy_scenes:
		var spawn_tile = map.get_spawnable_tiles(level_data.spawn_enemy_coords).pick_random()
		if not spawn_tile:
			print('no tiles to spawn for spawn enemy coords: ' + str(level_data.spawn_enemy_coords))
			return
		
		_on_init_enemy(enemy_scene, spawn_tile)


func init_civilians() -> void:
	assert(level_data.has('civilian_scenes'), 'Set civilian_scenes for level_data')
	assert(level_data.has('spawn_civilian_coords'), 'Set spawn_civilian_coords for level_data')
	civilians = []
	
	for civilian_scene in level_data.civilian_scenes:
		var civilian_instance = civilian_scenes[civilian_scene].instantiate() as Civilian
		add_sibling(civilian_instance)
		if Global.tutorial:
			tutorial_manager_script.init_civilian(civilian_instance, level)
		
		#civilian_instance.init(current_level_civilian)
		var spawn_tile = map.get_spawnable_tiles(level_data.spawn_civilian_coords).pick_random()
		if not spawn_tile:
			print('no tiles to spawn for spawn civilian coords: ' + str(level_data.spawn_civilian_coords))
			return
		
		civilian_instance.spawn(spawn_tile)
		
		civilian_instance.connect('action_push_back', _on_character_action_push_back)
		civilian_instance.connect('action_pull_front', _on_character_action_pull_front)
		civilian_instance.connect('action_hit_ally', _on_character_action_hit_ally)
		civilian_instance.connect('action_give_shield', _on_character_action_give_shield)
		civilian_instance.connect('action_slow_down', _on_character_action_slow_down)
		civilian_instance.connect('action_cross_push_back', _on_character_action_cross_push_back)
		civilian_instance.connect('action_indicators_cross_push_back', _on_action_indicators_cross_push_back)
		civilian_instance.connect('collectable_picked_event', _on_collectable_picked_event)
		
		civilians.push_back(civilian_instance)


func init_ui() -> void:
	for default_player_container in players_grid_container.get_children().filter(func(child): return child.is_in_group('ALWAYS_FREE')):
		default_player_container.queue_free()
	
	assert(players.size() >= 1 and players.size() <= 3, 'Wrong players size')
	for player in players:
		assert(player.id >= 0, 'Wrong player id')
		var player_container = player_container_scene.instantiate() as PlayerContainer
		player_container.init(player.id, _on_player_texture_button_mouse_entered, _on_player_texture_button_mouse_exited, _on_player_texture_button_toggled)
		player_container.init_stats(player.max_health, player.move_distance, player.damage, player.action_type)
		players_grid_container.add_child(player_container)


func start_turn() -> void:
	###############################################
	# ┏┓┏┓┳┳┓┏┓  ┳┳┓┏┓•┳┓  ┓ ┏┓┏┓┏┓  ┏┓┏┳┓┏┓┳┓┏┳┓ #
	# ┃┓┣┫┃┃┃┣   ┃┃┃┣┫┓┃┃  ┃ ┃┃┃┃┃┃  ┗┓ ┃ ┣┫┣┫ ┃  #
	# ┗┛┛┗┛ ┗┗┛  ┛ ┗┛┗┗┛┗  ┗┛┗┛┗┛┣┛  ┗┛ ┻ ┛┗┛┗ ┻  #
	###############################################
	
	await level_manager_script.plan_events(self)
	
	# actions order: events plan > civilians > enemies move and plan > players > enemies actions > events actions
	var alive_civilians: Array[Civilian] = civilians.filter(func(civilian: Civilian): return civilian.is_alive)
	var alive_enemies: Array[Enemy] = enemies.filter(func(enemy: Enemy): return enemy.is_alive)
	var alive_players: Array[Player] = players.filter(func(player: Player): return player.is_alive)
	
	for alive_civilian in alive_civilians:
		var tiles_for_movement = calculate_tiles_for_movement(true, alive_civilian)
		if tiles_for_movement.is_empty():
			tiles_for_movement.push_back(alive_civilian.tile)
		
		# prefer to move if possible
		var target_tile_for_movement = (tiles_for_movement[0]) if (tiles_for_movement.size() == 1) else (tiles_for_movement.filter(func(tile: MapTile): return tile != alive_civilian.tile)).pick_random()
		var tiles_path = calculate_tiles_path(alive_civilian, target_tile_for_movement)
		await alive_civilian.move(tiles_path)
		
		alive_civilian.reset_states()
		# recalculate_enemies_planned_actions is not necessary because civilians move before enemies plan their actions
	
	# NOT (enemy targets order: assets > civilians > players) -> all are of the same priority
	var target_tiles_for_enemy: Array[Array] = [
		alive_civilians.map(func(alive_civilian: Civilian): return alive_civilian.tile) +
		alive_players.map(func(alive_player: Player): return alive_player.tile)
	]
	var targetable_tiles = map.get_targetable_tiles()
	if not targetable_tiles.is_empty():
		#target_tiles_for_enemy.push_front(targetable_tiles)
		target_tiles_for_enemy[0] += targetable_tiles
	
	# sort by order
	alive_enemies.sort_custom(func(e1, e2): return e1.order < e2.order)
	for alive_enemy in alive_enemies:
		var tiles_for_movement = calculate_tiles_for_movement(true, alive_enemy)
		tiles_for_movement.push_back(alive_enemy.tile)
		var target_tile_for_movement = calculate_tile_for_movement_towards_characters(tiles_for_movement, alive_enemy, target_tiles_for_enemy)
		if not target_tile_for_movement:
			target_tile_for_movement = tiles_for_movement.pick_random()
			print('enemy ' + str(alive_enemy.tile.coords) + ' -> random move ' + str(target_tile_for_movement.coords))
		
		var tiles_path = calculate_tiles_path(alive_enemy, target_tile_for_movement)
		await alive_enemy.move(tiles_path)
		
		# wait for 'thinking' about action
		await get_tree().create_timer(0.3).timeout
	
		# enemy shouldn't but could have moved in front of the other enemy attack line
		recalculate_enemies_planned_actions()
		
		var tiles_for_action = calculate_tiles_for_action(true, alive_enemy)
		if tiles_for_action.is_empty():
			print('enemy ' + str(alive_enemy.tile.coords) + ' -> no actions available')
		else:
			var target_tile_for_action = calculate_tile_for_action_towards_characters(tiles_for_action, target_tiles_for_enemy)
			if not target_tile_for_action:
				# no friendly fire preferred
				var no_ff_tiles = tiles_for_action.filter(func(tile: MapTile): return not tile.enemy)
				if no_ff_tiles.is_empty():
					target_tile_for_action = tiles_for_action.pick_random()
				else:
					target_tile_for_action = no_ff_tiles.pick_random()
				print('enemy ' + str(alive_enemy.tile.coords) + ' -> random action ' + str(target_tile_for_action.coords))
			
			alive_enemy.plan_action(target_tile_for_action)
	
	for alive_player in alive_players:
		alive_player.start_turn()
	
	# UI
	on_button_disabled(end_turn_texture_button, false)
	
	await show_turn_end_texture_rect('PLAYER')


func end_turn() -> void:
	# UI
	on_button_disabled(end_turn_texture_button, true)
	on_button_disabled(undo_texture_button, true)
	action_first_texture_button.set_pressed_no_signal(false)
	undo = {}
	
	await show_turn_end_texture_rect('ENEMY')
	
	for player in players.filter(func(player: Player): return player.is_alive) as Array[Player]:
		#player.reset_phase()
		player.reset_tiles()
		player.reset_states()
		player.current_phase = PhaseType.WAIT
	
	enemies.sort_custom(func(e1, e2): return e1.order < e2.order)
	for enemy in enemies:
		# enemy could have been killed by another enemy inside this loop
		if enemy.is_alive:
			await enemy.execute_planned_action()
	
	await level_manager_script.execute_events(self)
	
	check_for_level_end()
	
	#########################################
	# ┏┓┏┓┳┳┓┏┓  ┳┳┓┏┓•┳┓  ┓ ┏┓┏┓┏┓  ┏┓┳┓┳┓ #
	# ┃┓┣┫┃┃┃┣   ┃┃┃┣┫┓┃┃  ┃ ┃┃┃┃┃┃  ┣ ┃┃┃┃ #
	# ┗┛┛┗┛ ┗┗┛  ┛ ┗┛┗┗┛┗  ┗┛┗┛┗┛┣┛  ┗┛┛┗┻┛ #
	#########################################


func next_turn() -> void:
	current_turn += 1
	
	game_info_label.text = 'LEVEL: ' + str(level) + '\n'
	game_info_label.text += 'TURN: ' + str(current_turn) + '\n'
	game_info_label.text += 'MONEY: ' + str(Global.money)
	
	for player in players:
		# hardcoded
		var player_texture_button = get_player_texture_button_by_id(player.id)
		on_button_disabled(player_texture_button, not player.is_alive)
		player_texture_button.flip_v = not player.is_alive
	
	start_turn()


func next_level() -> void:
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


func check_for_level_end(turn_ended: bool = true) -> void:
	var is_level_lost = level_manager_script.check_if_level_lost(self)
	if is_level_lost:
		level_lost()
		return
	
	var is_level_won = level_manager_script.check_if_level_won(self)
	if is_level_won:
		level_won()
		return
	
	if turn_ended:
		next_turn()


func level_won() -> void:
	var money_for_level: int = 0
	for tile in map.get_tiles_for_calculating_money():
		if tile.health_type == TileHealthType.HEALTHY or tile.health_type == TileHealthType.DESTRUCTIBLE_HEALTHY:
			money_for_level += 1
		elif tile.health_type == TileHealthType.DAMAGED or tile.health_type == TileHealthType.DESTRUCTIBLE_DAMAGED:
			# i know...
			money_for_level += 0
		elif tile.health_type == TileHealthType.DESTROYED:
			money_for_level -= 3
	
	print('added money for level: ' + str(money_for_level))
	if money_for_level > 0:
		Global.money += money_for_level
		print('now you have money: ' + str(Global.money))
	
	# TODO
	if level < max_levels and not Global.editor:
		level_end_label.text = 'LEVEL WON'
		level_end_popup.show()
		panel_full_screen_container.show()
		#next_level()
		#init(LevelType.TUTORIAL)
	else:
		print('WINNER WINNER!!!')


func level_lost() -> void:
	if not Global.editor:
		level_end_label.text = 'LEVEL LOST'
		level_end_popup.show()
		panel_full_screen_container.show()
	else:
		print('LOOOOOOST!!!')
		# TODO achievements
		print('achievement unlocked: you\'re a game journalist now')


func show_turn_end_texture_rect(whose_turn: String) -> void:
	pass
	# FIXME hardcoded
	#turn_end_label.text = whose_turn + ' TURN'
	#turn_end_texture_rect.show()
	#panel_full_screen_container.show()
	#
	#await get_tree().create_timer(0.5).timeout
	#
	#var turn_end_tween = create_tween()
	#turn_end_tween.tween_property(turn_end_texture_rect, 'modulate:a', 0, 1.0).from(1.0)
	#await turn_end_tween.finished
	#
	#panel_full_screen_container.hide()
	#turn_end_texture_rect.hide()
	#turn_end_texture_rect.modulate.a = 1.0
	#turn_end_label.text = ''
	#
	#if whose_turn == 'ENEMY':
		#await get_tree().create_timer(0.5).timeout


func reset_ui():
	game_info_label.text = 'LEVEL: ' + str(level) + '\n'
	game_info_label.text += 'TURN: ' + str(current_turn) + '\n'
	game_info_label.text += 'MONEY: ' + str(Global.money)
	tile_info_label.text = ''
	debug_info_label.text = ''


func calculate_tiles_for_movement(active: bool, character: Character) -> Array[MapTile]:
	var tiles_for_movement: Array[MapTile] = []
	
	if active:
		#tiles_for_movement.push_back(character.tile)
		var i = 1
		
		# don't even ask how this works
		var origin_tiles = [character.tile]
		var move_distance = (1) if (character.state_types.has(StateType.SLOWED_DOWN)) else (character.move_distance)
		
		while i <= move_distance:
			var temp_origin_tiles = []
			
			for origin_tile in origin_tiles:
				# can't walk into water/lava, can only be pushed there
				for tile in map.tiles.filter(func(tile: MapTile): return tile.health_type != TileHealthType.INDESTRUCTIBLE_WALKABLE) as Array[MapTile]:
					# characters can move through other characters of the same type
					var occupied_by_characters = (not character.is_in_group('PLAYERS') and tile.player) or (not character.is_in_group('ENEMIES') and tile.enemy) or (not character.is_in_group('CIVILIANS') and tile.civilian)
					if not occupied_by_characters and not tiles_for_movement.has(tile):
						if is_tile_adjacent(origin_tile, tile):
							push_unique_to_array(tiles_for_movement, tile)
							push_unique_to_array(temp_origin_tiles, tile)
						elif is_tile_adjacent(origin_tile, tile, not character.can_fly):
							push_unique_to_array(temp_origin_tiles, tile)
			
			origin_tiles = temp_origin_tiles
			i += 1
	else:
		return map.tiles
	
	# remove occupied tiles as target movement tiles
	return tiles_for_movement.filter(func(tile: MapTile): return not tile.player and not tile.enemy and not tile.civilian)


func is_tile_adjacent(origin_tile: MapTile, target_tile: MapTile, check_for_movement = true) -> bool:
	if check_for_movement and (target_tile.health_type == TileHealthType.DESTROYED or target_tile.health_type == TileHealthType.DESTRUCTIBLE_HEALTHY or target_tile.health_type == TileHealthType.DESTRUCTIBLE_DAMAGED or target_tile.health_type == TileHealthType.INDESTRUCTIBLE):
		return false
	
	return is_tile_adjacent_by_coords(origin_tile.coords, target_tile.coords)


func calculate_tiles_path(character: Character, target_tile: MapTile) -> Array[MapTile]:
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
	
	var tiles_path: Array[MapTile] = []
	tiles_path.append_array(tiles_coords_path.map(func(tile_coords: Vector2i): return map.tiles.filter(func(tile: MapTile): return tile.coords == tile_coords).front()))
	return tiles_path


func calculate_tiles_for_action(active: bool, character: Character) -> Array[MapTile]:
	var origin_tile = character.tile
	var tiles_for_action: Array[MapTile]
	
	if active:
		tiles_for_action = []
		
		if character.action_direction == ActionDirection.HORIZONTAL_LINE or character.action_direction == ActionDirection.HORIZONTAL_DOT:
			for tile in map.tiles.filter(func(tile: MapTile): return not tile.coords == character.tile.coords) as Array[MapTile]:
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
				var index = 0
				for tile in map.tiles.filter(func(tile: MapTile): return not tiles_for_action.has(tile)) as Array[MapTile]:
					if abs(tile.coords - origin_tile.coords) == Vector2i(i, i):
						# include all tiles in path
						if character.is_in_group('PLAYERS'):
							push_unique_to_array(tiles_for_action, tile)
						else:
							var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(character, character.tile.coords, tile.coords)
							if not first_occupied_tile_in_line:
								first_occupied_tile_in_line = tile
							
							push_unique_to_array(tiles_for_action, first_occupied_tile_in_line)
						
						index += 1
						# only four tiles can have valid coords for given 'i'
						if index == 4:
							break
		
		# exclude tiles behind occupied tiles
		if character.is_in_group('PLAYERS') and character.action_direction == ActionDirection.HORIZONTAL_LINE or character.action_direction == ActionDirection.VERTICAL_LINE:
			var occupied_tiles = tiles_for_action.filter(func(tile: MapTile): return tile.is_occupied()) as Array[MapTile]
			if not occupied_tiles.is_empty():
				for occupied_tile in occupied_tiles:
					var origin_to_target_sign = (character.tile.coords - occupied_tile.coords).sign()
					var hit_direction = get_hit_direction(origin_to_target_sign)
					if hit_direction == HitDirection.DOWN_LEFT:
						tiles_for_action = tiles_for_action.filter(func(tile: MapTile): return tile.coords.y != occupied_tile.coords.y or tile.coords.x <= occupied_tile.coords.x)
					elif hit_direction == HitDirection.UP_RIGHT:
						tiles_for_action = tiles_for_action.filter(func(tile: MapTile): return tile.coords.y != occupied_tile.coords.y or tile.coords.x >= occupied_tile.coords.x)
					elif hit_direction == HitDirection.RIGHT_DOWN:
						tiles_for_action = tiles_for_action.filter(func(tile: MapTile): return tile.coords.x != occupied_tile.coords.x or tile.coords.y <= occupied_tile.coords.y)
					elif hit_direction == HitDirection.LEFT_UP:
						tiles_for_action = tiles_for_action.filter(func(tile: MapTile): return tile.coords.x != occupied_tile.coords.x or tile.coords.y >= occupied_tile.coords.y)
					elif hit_direction == HitDirection.DOWN:
						tiles_for_action = tiles_for_action.filter(func(tile: MapTile): return tile.coords.x - tile.coords.y != occupied_tile.coords.x - occupied_tile.coords.y or tile.coords.x <= occupied_tile.coords.x)
					elif hit_direction == HitDirection.UP:
						tiles_for_action = tiles_for_action.filter(func(tile: MapTile): return tile.coords.x - tile.coords.y != occupied_tile.coords.x - occupied_tile.coords.y or tile.coords.x >= occupied_tile.coords.x)
					elif hit_direction == HitDirection.RIGHT:
						tiles_for_action = tiles_for_action.filter(func(tile: MapTile): return tile.coords.x - tile.coords.y >= occupied_tile.coords.x - occupied_tile.coords.y)
					elif hit_direction == HitDirection.LEFT:
						tiles_for_action = tiles_for_action.filter(func(tile: MapTile): return tile.coords.x - tile.coords.y <= occupied_tile.coords.x - occupied_tile.coords.y)
	else:
		tiles_for_action = map.tiles
	
	return tiles_for_action


func calculate_tile_for_movement_towards_characters(tiles_for_movement: Array[MapTile], origin_character: Character, different_target_tiles: Array[Array]) -> MapTile:
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
				valid_tiles_for_movement = target_tiles.filter(func(target_tile: MapTile): return \
					(target_tile.coords.x == tile_for_movement.coords.x and absi(target_tile.coords.y - tile_for_movement.coords.y) >= origin_character.action_min_distance and absi(target_tile.coords.y - tile_for_movement.coords.y) <= origin_character.action_max_distance) \
					or (target_tile.coords.y == tile_for_movement.coords.y and absi(target_tile.coords.x - tile_for_movement.coords.x) >= origin_character.action_min_distance and absi(target_tile.coords.x - tile_for_movement.coords.x) <= origin_character.action_max_distance))
				if not valid_tiles_for_movement.is_empty():
					target_tile_for_movement = tile_for_movement
			elif origin_character.action_direction == ActionDirection.VERTICAL_LINE or origin_character.action_direction == ActionDirection.VERTICAL_DOT:
				var min_range = maxi(1, origin_character.action_min_distance)
				var max_range = mini(map.get_side_dimension(), origin_character.action_max_distance)
				for i in range(min_range, max_range + 1):
					var valid_tiles = target_tiles.filter(func(target_tile: MapTile): return abs(target_tile.coords - tile_for_movement.coords) == Vector2i(i, i))
					if not valid_tiles.is_empty():
						valid_tiles_for_movement.append_array(valid_tiles)
			
				if not valid_tiles_for_movement.is_empty():
					target_tile_for_movement = tile_for_movement
			
			# exclude tiles behind occupied tiles
			if target_tile_for_movement and (origin_character.action_direction == ActionDirection.HORIZONTAL_LINE or origin_character.action_direction == ActionDirection.VERTICAL_LINE):
				if valid_tiles_for_movement.all(func(target_tile: MapTile): return target_tile != calculate_first_occupied_tile_for_action_direction_line(origin_character, target_tile_for_movement.coords, target_tile.coords)):
					valid_tiles_for_movement = []
					target_tile_for_movement = null
			
			if target_tile_for_movement:
				# exlude tiles in front of the other enemy attack line
				if origin_character.is_in_group('ENEMIES'):
					for other_enemy in enemies.filter(func(enemy: Enemy): return enemy != origin_character and enemy.planned_tile and (enemy.action_direction == ActionDirection.HORIZONTAL_LINE or enemy.action_direction == ActionDirection.VERTICAL_LINE)) as Array[Enemy]:
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


func calculate_tile_for_action_towards_characters(tiles_for_action: Array[MapTile], different_target_tiles: Array[Array]) -> MapTile:
	for target_tiles in different_target_tiles:
		# make it random
		tiles_for_action.shuffle()
		
		for tile_for_action in tiles_for_action:
			if target_tiles.any(func(target_tile: MapTile): return target_tile.coords == tile_for_action.coords):
				return tile_for_action
	
	return null


func calculate_first_occupied_tile_for_action_direction_line(origin_character: Character, origin_tile_coords: Vector2i, target_tile_coords: Vector2i) -> MapTile:
	if origin_character.action_direction == ActionDirection.HORIZONTAL_LINE or origin_character.action_direction == ActionDirection.VERTICAL_LINE:
		var hit_direction = (origin_tile_coords - target_tile_coords).sign()
		var tiles_in_line = []
		var min_range = maxi(1, origin_character.action_min_distance)
		var max_range = mini(map.get_side_dimension(), origin_character.action_max_distance)
		for i in range(min_range, max_range + 1):
			var current_tiles_in_line = map.tiles.filter(func(tile: MapTile): return tile.coords == origin_tile_coords - hit_direction * i)
			if not current_tiles_in_line.is_empty():
				push_unique_to_array(tiles_in_line, current_tiles_in_line.front())
		
		var occupied_tiles_in_line = tiles_in_line.filter(func(tile: MapTile): return (tile.health_type == TileHealthType.DESTRUCTIBLE_HEALTHY or tile.health_type == TileHealthType.DESTRUCTIBLE_DAMAGED or tile.health_type == TileHealthType.INDESTRUCTIBLE or (tile.player and not tile.player.is_ghost) or tile.ghost or tile.enemy or tile.civilian) and tile != origin_character.tile)
		if not occupied_tiles_in_line.is_empty():
			return occupied_tiles_in_line.front()
		
		return tiles_in_line.back()
	
	return null


func recalculate_enemies_planned_actions() -> void:
	for enemy in enemies.filter(func(enemy: Enemy): return enemy.is_alive and enemy.planned_tile) as Array[Enemy]:
		var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(enemy, enemy.tile.coords, enemy.planned_tile.coords)
		if first_occupied_tile_in_line:# and first_occupied_tile_in_line != enemy.planned_tile:
			enemy.plan_action(first_occupied_tile_in_line)
		else:
			# just to be sure and refresh arrows, indicators, etc.
			enemy.plan_action(enemy.planned_tile)
			
		# planned tile could've lost 'is_planned_enemy_action' true flag
		if not enemy.planned_tile.is_planned_enemy_action:
			enemy.planned_tile.set_planned_enemy_action(true)


func get_player_texture_button_by_id(id: int) -> TextureButton:
	#var player_container = get_player_container_by_index(index)
	var player_container = players_grid_container.get_children().filter(func(child): return child.id == id).front()
	return player_container.find_child('PlayerTextureButton')


func get_player_label_by_id_and_names(id: int, container_name: String, name: String) -> Label:
	#var player_container = get_player_container_by_index(index)
	var player_container = players_grid_container.get_children().filter(func(child): return child.id == id).front()
	var child = player_container.find_child(container_name)
	return child.find_child(name)


func set_clicked_player_texture_button(player_texture_button: TextureButton, is_clicked: bool) -> void:
	player_texture_button.modulate.a = (1.0) if (is_clicked) else (0.5)


func on_shoot_action_button_toggled(toggled_on: bool) -> void:
	if not selected_player:
		return
	
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
	
	if toggled_on and selected_player.can_make_action():
		var tiles_for_action = calculate_tiles_for_action(true, selected_player)
		for tile in tiles_for_action:
			tile.toggle_player_clicked(true)


func on_tile_hovered(target_tile: MapTile, is_hovered: bool) -> void:
	# reset all kinds of arrows, indicators, outlines, ...
	for player in players:
		player.is_ghost = false
		player.reset_health_bar()
		
		if player != selected_player:
			player.toggle_outline(false)
			player.toggle_health_bar(false)
	
	for tile in map.tiles:
		tile.ghost = null
		tile.toggle_shader(false)
		tile.toggle_text(false)
		
		if not is_hovered:
			tile.toggle_asset_outline(false)
		
		# reset other tiles
		if tile != target_tile:
			tile.is_hovered = false
			tile.reset_tile_models()
	
	for enemy in enemies:
		enemy.toggle_arrow_highlight(false)
		enemy.toggle_action_indicators(false)
		enemy.toggle_outline(false)
		enemy.toggle_health_bar(false)
		enemy.reset_health_bar()
	
	for civilian in civilians:
		civilian.toggle_outline(false)
		civilian.toggle_health_bar(false)
		civilian.reset_health_bar()
	
	if is_hovered:
		var is_selected_player_action = selected_player and selected_player.current_phase == PhaseType.ACTION and action_first_texture_button.is_pressed()
		var character = target_tile.get_character()
		# show health bar for hovered character
		if character:
			character.toggle_health_bar(true)
			
			if character.is_in_group('ENEMIES'):
				var enemy: Enemy = character
				if not is_selected_player_action:
					enemy.toggle_action_indicators(true)
		
		# outline hovered enemy and highlight his attack arrows
		if target_tile.enemy:
			#target_tile.enemy.toggle_outline(true)
			
			if target_tile.enemy.planned_tile:
				if not is_selected_player_action:
					target_tile.enemy.toggle_arrow_highlight(true)
					target_tile.enemy.planned_tile.toggle_asset_outline(true)
					
					# highlight tile itself if it's empty
					if not target_tile.enemy.planned_tile.is_occupied():
						#target_tile.enemy.planned_tile.toggle_shader(true)
						if target_tile.enemy.planned_tile.is_free():
							target_tile.enemy.planned_tile.toggle_text(true, str(target_tile.enemy.damage))
					
					# show outline with predicted health for enemy targets
					if target_tile.enemy.action_type == ActionType.CROSS_PUSH_BACK:
						# only for target tile
						target_tile.enemy.show_outline_with_predicted_health(target_tile.enemy.planned_tile, map.tiles, ActionType.NONE)
						
						# only for tiles to be cross pushed back
						for tile in map.tiles.filter(func(tile: MapTile): return is_tile_adjacent_by_coords(target_tile.enemy.planned_tile.coords, tile.coords)):
							# show outline with predicted health for enemy cross pushed targets
							target_tile.enemy.show_outline_with_predicted_health(tile, map.tiles, ActionType.CROSS_PUSH_BACK, target_tile.enemy.planned_tile, target_tile.enemy.action_damage)
					else:
						target_tile.enemy.show_outline_with_predicted_health(target_tile.enemy.planned_tile, map.tiles, target_tile.enemy.action_type)
		
		# highlight attack arrows of hovered planned target
		if target_tile.is_planned_enemy_action:
			#target_tile.toggle_shader(true)
			#target_tile.toggle_asset_outline(true)
			
			if not is_selected_player_action:
				# find enemy whose planned tile is hovered
				for enemy in enemies.filter(func(enemy: Enemy): return enemy.planned_tile == target_tile) as Array[Enemy]:
					enemy.toggle_outline(true)
					enemy.toggle_health_bar(true)
					#enemy.toggle_arrow_highlight(true)
	
	# highlight tiles while player is clicked
	if selected_player and selected_player.tile != target_tile and target_tile.is_player_clicked:
		if selected_player.can_move():
			#for other_tile in map.tiles.filter(func(tile: MapTile): return tile != target_tile):
				#other_tile.reset_tile_models()
			
			if is_hovered:
				var tiles_path = calculate_tiles_path(selected_player, target_tile)
				for next_tile in tiles_path:
					next_tile.on_mouse_entered()
				
				selected_player.look_at_y(target_tile)
				selected_player.is_ghost = true
				target_tile.ghost = selected_player
			
			recalculate_enemies_planned_actions()
		elif selected_player.can_make_action():
			if is_hovered:
				var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(selected_player, selected_player.tile.coords, target_tile.coords)
				if first_occupied_tile_in_line and first_occupied_tile_in_line != target_tile:
					target_tile.is_hovered = false
					target_tile.reset_tile_models()
				
					first_occupied_tile_in_line.is_hovered = true
					first_occupied_tile_in_line.reset_tile_models()
				else:
					first_occupied_tile_in_line = target_tile
				
				selected_player.look_at_y(first_occupied_tile_in_line)
				selected_player.spawn_arrow(first_occupied_tile_in_line)
				selected_player.spawn_action_indicators(first_occupied_tile_in_line)
				
				# highlight tile itself if it's empty
				if not first_occupied_tile_in_line.is_occupied():
					#first_occupied_tile_in_line.toggle_shader(true)
					if first_occupied_tile_in_line.is_free():
						first_occupied_tile_in_line.toggle_text(true, str(selected_player.damage))
				
				# show outline with predicted health for player targets
				if selected_player.action_type == ActionType.CROSS_PUSH_BACK:
					# only for target tile
					selected_player.show_outline_with_predicted_health(first_occupied_tile_in_line, map.tiles, ActionType.NONE)
					
					# only for tiles to be cross pushed back
					for tile in map.tiles.filter(func(tile: MapTile): return is_tile_adjacent_by_coords(first_occupied_tile_in_line.coords, tile.coords)):
						selected_player.show_outline_with_predicted_health(tile, map.tiles, ActionType.CROSS_PUSH_BACK, first_occupied_tile_in_line, selected_player.action_damage)
				else:
					selected_player.show_outline_with_predicted_health(first_occupied_tile_in_line, map.tiles, selected_player.action_type)
			else:
				selected_player.clear_arrows()
				selected_player.clear_action_indicators()


func _on_tile_hovered(target_tile: MapTile, is_hovered: bool) -> void:
	on_tile_hovered(target_tile, is_hovered)
	
	# UI
	if is_hovered:
		# ┏┳┓•┓ ┏┓  •┳┓┏┓┏┓
		#  ┃ ┓┃ ┣   ┓┃┃┣ ┃┃
		#  ┻ ┗┗┛┗┛  ┗┛┗┻ ┗┛
		
		var character = target_tile.get_character()
		# DEBUG
		debug_info_label.text = 'POSITION: ' + str(target_tile.position) + '\n'
		debug_info_label.text += 'COORDS: ' + str(target_tile.coords) + '\n'
		debug_info_label.text += 'HEALTH TYPE: ' + str(TileHealthType.keys()[target_tile.health_type]) + '\n\n'
		debug_info_label.text += 'TILE TYPE: ' + str(TileType.keys()[target_tile.tile_type]) + '\n'
		if character:
			debug_info_label.text += '\n\n' + character.model_name + '\n'
			debug_info_label.text += tr('INFO_HEALTH') + ': ' + str(character.health) + '/' + str(character.max_health) + '\n'
			debug_info_label.text += 'DAMAGE: ' + str(character.damage) + '\n'
			debug_info_label.text += 'ACTION TYPE: ' + str(ActionType.keys()[character.action_type]) + '\n'
			debug_info_label.text += 'ACTION DIRECTION: ' + str(ActionDirection.keys()[character.action_direction]) + '\n'
			debug_info_label.text += 'ACTION DISTANCE: ' + str(character.action_min_distance) + '-' + str(character.action_max_distance) + '\n'
			debug_info_label.text += 'MOVE DISTANCE: ' + str(character.move_distance) + '\n'
			if not character.state_types.is_empty():
				debug_info_label.text += 'STATE TYPE: ' + str(StateType.keys()[character.state_types[0]])
		if target_tile.models.get('event_asset'):
			if target_tile.models.event_asset.is_in_group('ENEMIES_FROM_BELOW_INDICATORS'):
				debug_info_label.text += '\n\n' + 'TILE LEVEL EVENT: ' + str(LevelEvent.keys()[LevelEvent.ENEMIES_FROM_BELOW]) + '\n'
			elif target_tile.models.event_asset.is_in_group('ENEMIES_FROM_ABOVE_INDICATORS'):
				debug_info_label.text += '\n\n' + 'TILE LEVEL EVENT: ' + str(LevelEvent.keys()[LevelEvent.ENEMIES_FROM_ABOVE]) + '\n'
			elif target_tile.models.event_asset.is_in_group('MISSLES_INDICATORS'):
				debug_info_label.text += '\n\n' + 'TILE LEVEL EVENT: ' + str(LevelEvent.keys()[LevelEvent.FALLING_MISSLE]) + '\n'
			elif target_tile.models.event_asset.is_in_group('ROCKS_INDICATORS'):
				debug_info_label.text += '\n\n' + 'TILE LEVEL EVENT: ' + str(LevelEvent.keys()[LevelEvent.FALLING_ROCK]) + '\n'
		
		if target_tile.info and not target_tile.info.is_empty():
			debug_info_label.text += '\n\n' + target_tile.info
		
		# tile and character hover info
		# TODO
		tile_info_label.text += '[TILE ICON] ' + tr('TILE_TYPE_' + str(TileType.keys()[target_tile.tile_type])) + '\n'
		if character:
			tile_info_label.text += '[ACTION ICON] ' + tr('ACTION_' + str(ActionType.keys()[character.action_type])) + '\n'
			if not character.is_in_group('PLAYERS'):
				tile_info_label.text += '[MOVE ICON] ' + str(character.move_distance) + '\n'
			if not character.state_types.is_empty():
				tile_info_label.text += '[STATE ICON] ' + str(StateType.keys()[character.state_types[0]]) + '\n'
			if character.is_in_group('ENEMIES'):
				tile_info_label.text += '[ORDER ICON] ' + str(character.order) + '\n'
		if target_tile.get_collectable():
				tile_info_label.text += '[COLLECTABLE ICON]' + '\n'
	else:
		tile_info_label.text = ''
		debug_info_label.text = ''


func _on_tile_clicked(target_tile: MapTile) -> void:
	for player in players:
		player.is_ghost = false
	
	for tile in map.tiles:
		tile.ghost = null
	
	recalculate_enemies_planned_actions()
	
	# highlighted tile is clicked while player is selected
	if selected_player and selected_player.tile != target_tile and target_tile.is_player_clicked:
		if selected_player.can_move():
			# remember player's last tile
			undo[selected_player.get_instance_id()] = selected_player.tile
			on_button_disabled(undo_texture_button, false)
			
			var tiles_path = calculate_tiles_path(selected_player, target_tile)
			await selected_player.move(tiles_path, false)
			
			recalculate_enemies_planned_actions()
		elif selected_player.can_make_action():
			selected_player.clear_arrows()
			selected_player.clear_action_indicators()
		
			var first_occupied_tile_in_line = calculate_first_occupied_tile_for_action_direction_line(selected_player, selected_player.tile.coords, target_tile.coords)
			if not first_occupied_tile_in_line:
				first_occupied_tile_in_line = target_tile
			
			# remember selected player to be able to get its id later
			var temp_selected_player = selected_player
			if action_first_texture_button.is_pressed():
				await selected_player.execute_action(first_occupied_tile_in_line)
			else:
				await selected_player.shoot(first_occupied_tile_in_line)
			
			# reset undo when action was executed
			undo = {}
			on_button_disabled(action_first_texture_button, true)
			on_button_disabled(undo_texture_button, true)
			
			var selected_player_texture_button = get_player_texture_button_by_id(temp_selected_player.id)
			on_button_disabled(selected_player_texture_button, true)
			selected_player_texture_button.flip_v = true
			
			# maybe not needed, because it's also checked after enemy's death
			check_for_level_end(false)
	# other player or selected player is clicked
	elif target_tile.player and (not selected_player or selected_player.tile == target_tile or selected_player.can_be_interacted_with()):
		target_tile.player.reset_phase()
		target_tile.player.on_clicked()
		action_first_texture_button.set_pressed_no_signal(false)


func _on_tile_action_cross_push_back(target_tile_coords: Vector2i, action_damage: int, origin_tile_coords: Vector2i) -> void:
	var tiles_to_be_pushed: Array[MapTile] = []
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


func _on_player_hovered(player: Player, is_hovered: bool) -> void:
	if selected_player and selected_player != player:
		return
	
	if is_hovered:
		if player.can_move():
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


func _on_player_clicked(player: Player, is_clicked: bool) -> void:
	# reset tiles for selected player if new player is selected
	if selected_player and selected_player != player and selected_player.can_be_interacted_with():
		selected_player.reset_tiles()
	
	var player_texture_button = get_player_texture_button_by_id(player.id)
	set_clicked_player_texture_button(player_texture_button, is_clicked)
	
	if is_clicked:
		on_button_disabled(action_first_texture_button, false)
		
		selected_player = player
		selected_player.toggle_health_bar(true)
		
		if player.can_move():
			var tiles_for_movement = calculate_tiles_for_movement(is_clicked, player)
			for tile_for_movement in tiles_for_movement:
				tile_for_movement.toggle_player_clicked(is_clicked)
		#elif player.current_phase == PhaseType.ACTION:
			#var tiles_for_action = calculate_tiles_for_action(is_clicked, player)
			#for tile_for_action in tiles_for_action:
				#tile_for_action.toggle_player_clicked(is_clicked)
	else:
		on_button_disabled(action_first_texture_button, true)
		
		selected_player.toggle_health_bar(false)
		selected_player = null
		
		for tile in map.tiles:
			#tile.toggle_player_hovered(false)
			tile.toggle_player_clicked(false)
	
	player.tile.on_mouse_entered()


func _on_player_health_changed(target_player: Player):
	var player_health_label = get_player_label_by_id_and_names(target_player.id, 'HealthHBoxContainer', 'HealthLabel')
	player_health_label.text = str(target_player.health) + '/' + str(target_player.max_health)


func _on_init_enemy(enemy_scene: int, spawn_tile: MapTile) -> void:
	var enemy_instance = enemy_scenes[enemy_scene].instantiate() as Enemy
	if Global.tutorial:
		tutorial_manager_script.init_enemy(enemy_instance, level)
	
	add_sibling(enemy_instance)
	
	# find max order
	var enemies_orders = enemies.map(func(enemy): return enemy.order)
	var max_order = (0) if (enemies_orders.is_empty()) else (enemies_orders.max())
	enemy_instance.spawn(spawn_tile, max_order + 1)
	
	enemy_instance.connect('action_push_back', _on_character_action_push_back)
	enemy_instance.connect('action_pull_front', _on_character_action_pull_front)
	enemy_instance.connect('action_hit_ally', _on_character_action_hit_ally)
	enemy_instance.connect('action_give_shield', _on_character_action_give_shield)
	enemy_instance.connect('action_slow_down', _on_character_action_slow_down)
	enemy_instance.connect('action_cross_push_back', _on_character_action_cross_push_back)
	enemy_instance.connect('action_indicators_cross_push_back', _on_action_indicators_cross_push_back)
	enemy_instance.connect('planned_action_miss_move', _on_enemy_planned_action_miss_move)
	enemy_instance.connect('planned_action_miss_action', _on_enemy_planned_action_miss_action)
	enemy_instance.connect('killed_event', _on_enemy_killed_event)
	enemy_instance.connect('collectable_picked_event', _on_collectable_picked_event)
	
	enemies.push_back(enemy_instance)


func _on_enemy_planned_action_miss_move(target_character: Character, is_applied: bool) -> void:
	if is_applied:
		target_character.state_types.push_back(StateType.MISSED_MOVE)
	else:
		target_character.state_types.erase(StateType.MISSED_MOVE)


func _on_enemy_planned_action_miss_action(target_character: Character, is_applied: bool) -> void:
	if is_applied:
		target_character.state_types.push_back(StateType.MISSED_ACTION)
		
		if target_character.is_in_group('ENEMIES'):
			var enemy: Enemy = target_character
			enemy.reset_planned_tile()
	else:
		target_character.state_types.erase(StateType.MISSED_ACTION)


func _on_enemy_killed_event(target_enemy: Enemy) -> void:
	enemies_killed += 1
	
	# recalculate enemies order
	var order = 1
	enemies.sort_custom(func(e1, e2): return e1.order < e2.order)
	for alive_enemy in enemies.filter(func(enemy: Enemy): return enemy.is_alive) as Array[Enemy]:
		alive_enemy.order = order
		order += 1
	
	check_for_level_end(false)


func _on_character_action_push_back(target_character: Character, action_damage: int, origin_tile_coords: Vector2i) -> void:
	var hit_direction = (origin_tile_coords - target_character.tile.coords).sign()
	var push_direction = -1 * hit_direction
	# find tile pushed into
	var pushed_into_tiles = map.tiles.filter(func(tile: MapTile): return tile.coords == target_character.tile.coords + push_direction)
	if pushed_into_tiles.is_empty():
		var outside_tile_position = target_character.tile.position + Vector3(push_direction.y, 0, push_direction.x)
		# pushed outside of the map
		await target_character.move([target_character.tile] as Array[MapTile], true, outside_tile_position)
	else:
		var pushed_into_tile = pushed_into_tiles.front()
		await target_character.move([pushed_into_tile] as Array[MapTile], true)
		
		if target_character.is_alive and target_character.tile:
			# tile type hole or other destroyed tile
			if target_character.tile.health_type == TileHealthType.DESTROYED:
				# pushed into a hole = dead
				await target_character.get_killed()
			else:
				if target_character.tile.health_type == TileHealthType.INDESTRUCTIBLE_WALKABLE:
					target_character.state_types.push_back(StateType.MISSED_ACTION)
					target_character.state_types.push_back(StateType.SLOWED_DOWN)
				
				if target_character.tile == pushed_into_tile and target_character.is_in_group('ENEMIES'):
					# enemy actually moved
					var enemy: Enemy = target_character
					if enemy.planned_tile:
						# push planned tile with pushed enemy
						var planned_tiles = map.tiles.filter(func(tile: MapTile): return tile.coords == enemy.planned_tile.coords + push_direction)
						if planned_tiles.is_empty():
							print('enemy ' + str(enemy.tile.coords) + ' -> planned tile cannot be pushed back')
							enemy.reset_planned_tile()
						else:
							enemy.plan_action(planned_tiles.front())
	
	recalculate_enemies_planned_actions()


func _on_character_action_pull_front(target_character: Character, action_damage: int, origin_tile_coords: Vector2i) -> void:
	var hit_direction = (origin_tile_coords - target_character.tile.coords).sign()
	var pull_direction = hit_direction
	# find tile pulled into
	var pulled_into_tiles = map.tiles.filter(func(tile: MapTile): return tile.coords == target_character.tile.coords + pull_direction)
	if pulled_into_tiles.is_empty():
		var outside_tile_position = target_character.tile.position + Vector3(pull_direction.y, 0, pull_direction.x)
		# pulled outside of the map - is this even possible?
		await target_character.move([target_character.tile] as Array[MapTile], true, outside_tile_position)
	else:
		var pulled_into_tile = pulled_into_tiles.front()
		await target_character.move([pulled_into_tile] as Array[MapTile], true)
		
		if target_character.is_alive and target_character.tile:
			# tile type hole or other destroyed tile
			if target_character.tile.health_type == TileHealthType.DESTROYED:
				# pulled into a hole = dead
				await target_character.get_killed()
			else:
				if target_character.tile.health_type == TileHealthType.INDESTRUCTIBLE_WALKABLE:
					target_character.state_types.push_back(StateType.MISSED_ACTION)
					target_character.state_types.push_back(StateType.SLOWED_DOWN)
				
				if target_character.tile == pulled_into_tile and target_character.is_in_group('ENEMIES'):
					# enemy actually moved
					var enemy: Enemy = target_character
					if enemy.planned_tile:
						# pull planned tile with pulled enemy
						var planned_tiles = map.tiles.filter(func(tile: MapTile): return tile.coords == enemy.planned_tile.coords + pull_direction)
						if planned_tiles.is_empty():
							print('enemy ' + str(enemy.tile.coords) + ' -> planned tile cannot be pulled front')
							enemy.reset_planned_tile()
						else:
							enemy.plan_action(planned_tiles.front())
	
	recalculate_enemies_planned_actions()


func _on_character_action_hit_ally(target_character: Character) -> void:
	target_character.state_types.push_back(StateType.MADE_HIT_ALLY)


func _on_character_action_give_shield(target_character: Character) -> void:
	target_character.state_types.push_back(StateType.GAVE_SHIELD)


func _on_character_action_slow_down(target_character: Character) -> void:
	target_character.state_types.push_back(StateType.SLOWED_DOWN)


func _on_character_action_cross_push_back(target_character: Character, action_damage: int, origin_tile_coords: Vector2i) -> void:
	# does this even work if it's called from signal? i don't think so...
	await _on_tile_action_cross_push_back(target_character.tile.coords, action_damage, origin_tile_coords)


func _on_action_indicators_cross_push_back(target_character: Character, origin_tile: MapTile, first_origin_position: Vector3) -> void:
	for tile in map.tiles.filter(func(tile: MapTile): return is_tile_adjacent_by_coords(origin_tile.coords, tile.coords)) as Array[MapTile]:
		target_character.spawn_action_indicators(tile, origin_tile, first_origin_position, ActionType.PUSH_BACK)


func _on_collectable_picked_event(target_character: Character):
	undo = {}
	on_button_disabled(undo_texture_button, true)


func _on_end_turn_texture_button_pressed() -> void:
	end_turn()


func _on_action_texture_button_toggled(toggled_on: bool) -> void:
	on_shoot_action_button_toggled(toggled_on)


func _on_undo_texture_button_pressed() -> void:
	if not undo.is_empty():
		var last_undo_player_instance_id = undo.keys().back()
		var last_undo_player = players.filter(func(player: Player): return player.get_instance_id() == last_undo_player_instance_id).front()
		var last_undo_tile = undo[last_undo_player_instance_id]
		last_undo_player.position = last_undo_tile.position
		last_undo_player.tile.set_player(null)
		last_undo_player.tile = last_undo_tile
		last_undo_tile.set_player(last_undo_player)
		
		undo.erase(last_undo_player_instance_id)
		if undo.is_empty():
			on_button_disabled(undo_texture_button, true)
		
		last_undo_player.start_turn()
		
		recalculate_enemies_planned_actions()


func _on_player_texture_button_mouse_entered(id: int) -> void:
	if players.is_empty():
		return
	
	assert(id >= 0, 'Wrong id for player texture button')
	var target_player = players.filter(func(player): return player.id == id).front()
	if not target_player.is_alive:
		return
	
	on_tile_hovered(target_player.tile, true)
	_on_player_hovered(target_player, true)


func _on_player_texture_button_mouse_exited(id: int) -> void:
	if players.is_empty():
		return
	
	var target_player = players.filter(func(player): return player.id == id).front()
	if not target_player.is_alive:
		return
	
	on_tile_hovered(target_player.tile, false)
	_on_player_hovered(target_player, false)


func _on_player_texture_button_toggled(toggled_on: bool, id: int) -> void:
	if players.is_empty():
		return
	
	var target_player = players.filter(func(player): return player.id == id).front()
	if not target_player.is_alive or not target_player.can_be_interacted_with():
		return
	
	var player_texture_button = get_player_texture_button_by_id(target_player.id)
	set_clicked_player_texture_button(player_texture_button, toggled_on)
	
	_on_tile_clicked(target_player.tile)
	#_on_player_clicked(target_player, toggled_on)


func _on_level_end_popup_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if level_end_clicked:
			return
		
		level_end_clicked = true
		
		for alive_player in players.filter(func(player: Player): return player.is_alive):
			var flying_tile_tween = create_tween()
			flying_tile_tween.tween_property(alive_player, 'position:y', 9, 0.5)
			await flying_tile_tween.finished
	
		for alive_enemy in enemies.filter(func(enemy: Enemy): return enemy.is_alive):
			var flying_tile_tween = create_tween()
			flying_tile_tween.tween_property(alive_enemy, 'position:y', 9, 0.5)
			await flying_tile_tween.finished
		
		for alive_civilian in civilians.filter(func(civilian: Civilian): return civilian.is_alive):
			var flying_tile_tween = create_tween()
			flying_tile_tween.tween_property(alive_civilian, 'position:y', 9, 0.5)
			await flying_tile_tween.finished
		
		var index: float = 0.0
		for tile in map.tiles:
			var flying_tile_tween = create_tween()
			# speed up
			var duration = maxf(0.05, 0.2 - index)
			flying_tile_tween.tween_property(tile, 'position:y', 9, duration)
			await flying_tile_tween.finished
			index += 0.005
		
		panel_full_screen_container.hide()
		level_end_popup.hide()
		level_end_label.text = ''
		
		progress()
		
		level_end_clicked = false
