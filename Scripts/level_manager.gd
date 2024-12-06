extends Util

class_name LevelManager

signal init_enemy_event(enemy_scene: int, spawn_tile: MapTile)

const SAVED_LEVELS_FILE_PATH: String = 'res://Other/saved_levels.txt'
const TUTORIAL_LEVELS_FILE_PATH: String = 'res://Other/tutorial_levels.txt'

var spawn_from_below: bool = false


func generate_data(level_type: LevelType, level: int, enemy_scenes_size: int, civilian_scenes_size: int) -> Dictionary:
	var levels_file_path = get_levels_file_path(level_type)
	var file = FileAccess.open(levels_file_path, FileAccess.READ)
	var file_content = file.get_as_text()
	# FIXME use level
	var level_data_string = select_random_level_data(file_content, 1, level_type)
	assert(level_data_string != file_content, 'Add level type: ' + str(level_type) + ' to levels file: ' + str(levels_file_path))
	var level_data = parse_data(level_data_string)
	
	add_characters(level_data, enemy_scenes_size, civilian_scenes_size)
	add_events_details(level_data, enemy_scenes_size)
	add_level_type_details(level_data)
	
	return level_data


func parse_data(level_data_string: String) -> Dictionary:
	var json = JSON.new()
	var parse_status = json.parse(level_data_string)
	assert(parse_status == OK, json.get_error_message() + ' in ' + level_data_string.split('\n')[json.get_error_line()])
	return json.data


func get_levels_file_path(level_type: LevelType) -> String:
	if level_type == LevelType.TUTORIAL:
		return TUTORIAL_LEVELS_FILE_PATH
	
	return SAVED_LEVELS_FILE_PATH


func select_random_level_data(file_content: String, level: int, level_type: LevelType) -> String:
	var prefix = '-' + str(level) + '-' + str(level_type) + '->'
	
	if level_type == LevelType.TUTORIAL:
		return file_content.get_slice(str(level) + prefix + 'START', 1).get_slice(str(level) + prefix + 'STOP', 0)#.strip_escapes()
	
	var index = file_content.count(prefix + 'START')
	var indices_range = range(1, index)
	if Global.played_maps_indices.size() < indices_range.size():
		# prevent selecting already played maps
		indices_range = indices_range.filter(func(index): return not Global.played_maps_indices.has(index))
		assert(not indices_range.is_empty(), 'Empty indices for selected maps')
	else:
		# clear if all maps were already played (sic!)
		Global.played_maps_indices.clear()
	
	var random_index = indices_range.pick_random()
	Global.played_maps_indices.push_back(random_index)
	print('selected level: ' + str(random_index) + prefix)
	return file_content.get_slice(str(random_index) + prefix + 'START', 1).get_slice(str(random_index) + prefix + 'STOP', 0)#.strip_escapes()


func add_characters(level_data: Dictionary, enemy_scenes_size: int, civilian_scenes_size: int) -> void:
	level_data.player_scenes = []
	level_data.enemy_scenes = []
	level_data.civilian_scenes = []
	
	if level_data.level_type == LevelType.TUTORIAL:
		# TODO FIXME hardcoded
		if level_data.level == 1:
			level_data.player_scenes.push_back(0)
			level_data.enemy_scenes.push_back(0)
		elif level_data.level == 2:
			level_data.player_scenes.push_back(0)
			level_data.enemy_scenes.push_back(0)
	else:
		for selected_player in Global.selected_players:
			level_data.player_scenes.push_back(selected_player.id)
		
		if level_data.level_type == LevelType.KILL_ENEMIES:
			# scene 0 is always tutorial
			# TODO pick enemies and civilians by random(?) based on level type and level number
			level_data.enemy_scenes.push_back(randi_range(1, enemy_scenes_size - 1))
			level_data.enemy_scenes.push_back(randi_range(1, enemy_scenes_size - 1))
			level_data.enemy_scenes.push_back(randi_range(1, enemy_scenes_size - 1))
		else:
			level_data.enemy_scenes.push_back(randi_range(1, enemy_scenes_size - 1))
			level_data.enemy_scenes.push_back(randi_range(1, enemy_scenes_size - 1))
			level_data.enemy_scenes.push_back(randi_range(1, enemy_scenes_size - 1))
			level_data.civilian_scenes.push_back(randi_range(1, civilian_scenes_size - 1))


func add_level_type_details(level_data: Dictionary) -> void:
	if level_data.level_type == LevelType.KILL_ENEMIES:
		var enemies_from_below_size = level_data.level_events.filter(func(level_event): return level_event == LevelEvent.ENEMIES_FROM_BELOW).size()
		var enemies_from_below_turns_size = (1 + level_data.enemies_from_below_last_turn - level_data.enemies_from_below_first_turn) if (enemies_from_below_size > 0) else (0)
		var enemies_from_above_size = level_data.level_events.filter(func(level_event): return level_event == LevelEvent.ENEMIES_FROM_ABOVE).size()
		var enemies_from_above_turns_size = (1 + level_data.enemies_from_above_last_turn - level_data.enemies_from_above_first_turn) if (enemies_from_above_size > 0) else (0)
		# FIXME hardcoded
		level_data.max_enemies = 3 + enemies_from_below_size * enemies_from_below_turns_size + enemies_from_above_size * enemies_from_above_turns_size
	elif level_data.level_type == LevelType.SURVIVE_TURNS:
		# FIXME hardcoded
		level_data.max_turns = 5


func add_events_details(level_data: Dictionary, enemy_scenes_size: int) -> void:
	if not level_data.has('level_events'):
		return
	
	for level_event in level_data.level_events:
		if level_event == LevelEvent.ENEMIES_FROM_BELOW:
			if not level_data.has('enemies_from_below'):
				level_data.enemies_from_below = []
			
			level_data.enemies_from_below.push_back(randi_range(1, enemy_scenes_size - 1))
			# FIXME hardcoded
			level_data.enemies_from_below_first_turn = 2
			level_data.enemies_from_below_last_turn = 4
		elif level_event == LevelEvent.ENEMIES_FROM_ABOVE:
			if not level_data.has('enemies_from_above'):
				level_data.enemies_from_above = []
			
			level_data.enemies_from_above.push_back(randi_range(1, enemy_scenes_size - 1))
			# FIXME hardcoded
			level_data.enemies_from_above_first_turn = 2
			level_data.enemies_from_above_last_turn = 4
			


func plan_events(game_state_manager: GameStateManager) -> void:
	var map = game_state_manager.map
	var level_data = game_state_manager.level_data
	var current_turn = game_state_manager.current_turn
	
	if not level_data.has('level_events'):
		return
	
	var enemies_from_below_size = level_data.level_events.filter(func(level_event: LevelEvent): return level_event == LevelEvent.ENEMIES_FROM_BELOW).size()
	var enemies_from_above_size = level_data.level_events.filter(func(level_event: LevelEvent): return level_event == LevelEvent.ENEMIES_FROM_ABOVE).size()
	for level_event in level_data.level_events:
		# enemy spawned near spawn_enemy_coords from below
		if level_event == LevelEvent.ENEMIES_FROM_BELOW:
			assert(level_data.has('enemies_from_below_first_turn'), 'Set enemies_from_below_first_turn for level_event: ENEMIES_FROM_BELOW')
			assert(level_data.has('enemies_from_below_last_turn'), 'Set enemies_from_below_last_turn for level_event: ENEMIES_FROM_BELOW')
			if current_turn >= level_data.enemies_from_below_first_turn and current_turn <= level_data.enemies_from_below_last_turn:
				# check if some indicators were left from the last turn
				var existing_event_tiles_size = map.tiles.filter(func(tile: MapTile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('ENEMIES_FROM_BELOW_INDICATORS')).size()
				if existing_event_tiles_size >= enemies_from_below_size:
					return
				
				var event_asset = map.assets.filter(func(asset): return asset.name == 'indicator-special-cross').front().duplicate()
				var event_asset_material = StandardMaterial3D.new()
				event_asset_material.albedo_color = Color('FFFF00')#yellow
				event_asset.set_surface_override_material(0, event_asset_material)
				
				assert(level_data.has('spawn_enemy_coords'), 'Set spawn_enemy_coords for level_event: ENEMIES_FROM_BELOW')
				var vector2i_spawn_enemy_coords = convert_spawn_coords_to_vector_coords(level_data.spawn_enemy_coords)
				var spawn_enemy_positions = map.tiles.filter(func(tile: MapTile): return vector2i_spawn_enemy_coords.has(tile.coords)).map(func(tile: MapTile): return tile.position)
				var event_tiles = map.get_untargetable_tiles().filter(func(tile: MapTile): return tile.can_be_occupied() and not spawn_enemy_positions.has(tile.position) and spawn_enemy_positions.any(func(spawn_enemy_position): return spawn_enemy_position.distance_to(tile.position) <= 1.5))
				if event_tiles.is_empty():
					print('no more enemies from below indicator spawned')
					return
				
				var empty_event_tiles = event_tiles.filter(func(event_tile: MapTile): return not event_tile.get_character())
				var event_tile = (event_tiles.pick_random()) if (empty_event_tiles.is_empty()) else (empty_event_tiles.pick_random())
				event_tile.models.event_asset = event_asset.duplicate()
				event_tile.models.event_asset.add_to_group('ENEMIES_FROM_BELOW_INDICATORS')
				event_tile.models.event_asset.show()
				event_tile.add_child(event_tile.models.event_asset)
				
				print('more enemy from below at ' + str(event_tile.coords))
				await game_state_manager.get_tree().create_timer(1.0).timeout
		# enemy spawned near spawn_enemy_coords from above
		elif level_event == LevelEvent.ENEMIES_FROM_ABOVE:
			assert(level_data.has('enemies_from_above_first_turn'), 'Set enemies_from_above_first_turn for level_event: ENEMIES_FROM_ABOVE')
			assert(level_data.has('enemies_from_above_last_turn'), 'Set enemies_from_above_last_turn for level_event: ENEMIES_FROM_ABOVE')
			if current_turn >= level_data.enemies_from_above_first_turn and current_turn <= level_data.enemies_from_above_last_turn:
				# check if some indicators were left from the last turn
				var existing_event_tiles_size = map.tiles.filter(func(tile: MapTile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('ENEMIES_FROM_ABOVE_INDICATORS')).size()
				if existing_event_tiles_size >= enemies_from_above_size:
					return
				
				var event_asset = map.assets.filter(func(asset): return asset.name == 'indicator-special-cross').front().duplicate()
				var event_asset_material = StandardMaterial3D.new()
				event_asset_material.albedo_color = Color('FFFF00')#yellow
				event_asset.set_surface_override_material(0, event_asset_material)
				
				assert(level_data.has('spawn_enemy_coords'), 'Set spawn_enemy_coords for level_event: ENEMIES_FROM_ABOVE')
				var vector2i_spawn_enemy_coords = convert_spawn_coords_to_vector_coords(level_data.spawn_enemy_coords)
				var spawn_enemy_positions: Array = map.tiles.filter(func(tile: MapTile): return vector2i_spawn_enemy_coords.has(tile.coords)).map(func(tile: MapTile): return tile.position)
				var event_tiles = map.get_untargetable_tiles().filter(func(tile: MapTile): return tile.can_be_occupied() and not spawn_enemy_positions.has(tile.position) and spawn_enemy_positions.any(func(spawn_enemy_position: Vector3): return spawn_enemy_position.distance_to(tile.position) <= 1.5))
				if event_tiles.is_empty():
					print('no more enemies from above indicator spawned')
					return
				
				var empty_event_tiles = event_tiles.filter(func(event_tile: MapTile): return not event_tile.get_character())
				var event_tile = (event_tiles.pick_random()) if (empty_event_tiles.is_empty()) else (empty_event_tiles.pick_random())
				event_tile.models.event_asset = event_asset.duplicate()
				event_tile.models.event_asset.add_to_group('ENEMIES_FROM_ABOVE_INDICATORS')
				event_tile.models.event_asset.show()
				event_tile.add_child(event_tile.models.event_asset)
				
				print('more enemy from above at ' + str(event_tile.coords))
				await game_state_manager.get_tree().create_timer(1.0).timeout
		# missle spawned at random tile
		elif level_event == LevelEvent.FALLING_MISSLE:
			if current_turn > 1:
				var event_asset = map.assets.filter(func(asset): return asset.name == 'indicator-special-cross').front().duplicate()
				var event_asset_material = StandardMaterial3D.new()
				event_asset_material.albedo_color = Color('FF0000')#red
				event_asset.set_surface_override_material(0, event_asset_material)
				
				var event_tiles = map.get_untargetable_tiles()
				if event_tiles.is_empty():
					print('no missle indicator spawned')
					return
				
				var event_tile = event_tiles.pick_random()
				event_tile.models.event_asset = event_asset.duplicate()
				event_tile.models.event_asset.add_to_group('MISSLES_INDICATORS')
				event_tile.models.event_asset.show()
				event_tile.add_child(event_tile.models.event_asset)
				
				print('spawned missle at ' + str(event_tile.coords))
				await game_state_manager.get_tree().create_timer(1.0).timeout
		# rock spawned near mountains
		elif level_event == LevelEvent.FALLING_ROCK:
			if current_turn > 1:
				var event_asset = map.assets.filter(func(asset): return asset.name == 'indicator-special-cross').front().duplicate()
				var event_asset_material = StandardMaterial3D.new()
				event_asset_material.albedo_color = Color('7A5134')#brown
				event_asset.set_surface_override_material(0, event_asset_material)
				
				var mountain_positions: Array = map.tiles.filter(func(tile: MapTile): return tile.tile_type == TileType.MOUNTAIN).map(func(tile: MapTile): return tile.position)
				assert(not mountain_positions.is_empty(), 'Set mountain_positions for level_event: FALLING_ROCK')
				var event_tiles = map.get_untargetable_tiles().filter(func(tile: MapTile): return not mountain_positions.has(tile.position) and mountain_positions.any(func(mountain_position: Vector3): return mountain_position.distance_to(tile.position) <= 1.5))
				if event_tiles.is_empty():
					print('no rock indicator spawned')
					return
				
				var event_tile = event_tiles.pick_random()
				event_tile.models.event_asset = event_asset.duplicate()
				event_tile.models.event_asset.add_to_group('ROCKS_INDICATORS')
				event_tile.models.event_asset.show()
				event_tile.add_child(event_tile.models.event_asset)
				
				print('spawned rock at ' + str(event_tile.coords))
				await game_state_manager.get_tree().create_timer(1.0).timeout
		#TODO more
		else:
			print('no implementation of planning level event: ' + LevelEvent.keys()[level_event])


func execute_events(game_state_manager: GameStateManager) -> void:
	var map = game_state_manager.map
	var level_data = game_state_manager.level_data
	var current_turn = game_state_manager.current_turn
	
	if not level_data.has('level_events'):
		return
	
	var enemies_from_below_index = 0
	var enemies_from_above_index = 0
	var already_checked_enemies_tiles = []
	for level_event in level_data.level_events:
		# enemy spawns from below at spawned indicators - if occupied then do damage to character and try to spawn next turn
		if level_event == LevelEvent.ENEMIES_FROM_BELOW:
			assert(level_data.has('enemies_from_below_first_turn'), 'Set enemies_from_below_first_turn for level_event: ENEMIES_FROM_BELOW')
			assert(level_data.has('enemies_from_below_last_turn'), 'Set enemies_from_below_last_turn for level_event: ENEMIES_FROM_BELOW')
			assert(level_data.get('enemies_from_below'), 'Set enemies_from_below for level_event: ENEMIES_FROM_ABOVE')
			if current_turn >= level_data.enemies_from_below_first_turn and current_turn <= level_data.enemies_from_below_last_turn:
				var event_tile: MapTile = map.tiles.filter(func(tile: MapTile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('ENEMIES_FROM_BELOW_INDICATORS') and not already_checked_enemies_tiles.has(tile)).front()
				if not event_tile:
					print('no event tiles for ENEMIES_FROM_BELOW');
					continue
				
				var target_character = event_tile.get_character()
				if target_character:
					already_checked_enemies_tiles.push_back(event_tile)
					await event_tile.get_shot(1)
					continue
				
				# TODO animation
				var spawned_enemy_scene = level_data.enemies_from_below[enemies_from_below_index]
				init_enemy_event.emit(spawned_enemy_scene, event_tile)
				
				event_tile.models.event_asset.queue_free()
				event_tile.models.erase('event_asset')
				enemies_from_below_index += 1
				
				await game_state_manager.get_tree().create_timer(1.0).timeout
		# enemy spawns from above at spawned indicators - if occupied then don't spawn and try next turn
		elif level_event == LevelEvent.ENEMIES_FROM_ABOVE:
			assert(level_data.has('enemies_from_above_first_turn'), 'Set enemies_from_above_first_turn for level_event: ENEMIES_FROM_ABOVE')
			assert(level_data.has('enemies_from_above_last_turn'), 'Set enemies_from_above_last_turn for level_event: ENEMIES_FROM_ABOVE')
			assert(level_data.get('enemies_from_above'), 'Set enemies_from_above for level_event: ENEMIES_FROM_ABOVE')
			if current_turn >= level_data.enemies_from_above_first_turn and current_turn <= level_data.enemies_from_above_last_turn:
				var event_tile = map.tiles.filter(func(tile: MapTile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('ENEMIES_FROM_BELOW_INDICATORS') and not already_checked_enemies_tiles.has(tile)).front()
				if not event_tile or event_tile.get_character():
					print('no event tiles or character on tile for ENEMIES_FROM_ABOVE');
					already_checked_enemies_tiles.push_back(event_tile)
					continue
				
				# TODO animation
				var spawned_enemy_scene = level_data.enemies_from_above[enemies_from_above_index]
				init_enemy_event.emit(spawned_enemy_scene, event_tile)
				
				event_tile.models.event_asset.queue_free()
				event_tile.models.erase('event_asset')
				enemies_from_above_index += 1
				
				await game_state_manager.get_tree().create_timer(1.0).timeout
		# missle hits at spawned indicators
		elif level_event == LevelEvent.FALLING_MISSLE:
			if current_turn > 1:
				var event_tile = map.tiles.filter(func(tile: MapTile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('MISSLES_INDICATORS')).front()
				if not event_tile:
					continue
				
				# TODO add bullet spawn
				await event_tile.get_shot(1)
				
				event_tile.models.event_asset.queue_free()
				event_tile.models.erase('event_asset')
		# rock hits at spawned indicators
		elif level_event == LevelEvent.FALLING_ROCK:
			if current_turn > 1:
				var event_tile = map.tiles.filter(func(tile: MapTile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('ROCKS_INDICATORS')).front()
				if not event_tile:
					continue
				
				# TODO add bullet spawn
				await event_tile.get_shot(1)
				
				event_tile.models.event_asset.queue_free()
				event_tile.models.erase('event_asset')
		#TODO else...
		else: print('no implementation of executing level event: ' + LevelEvent.keys()[level_event])


func check_if_level_lost(game_state_manager: GameStateManager) -> bool:
	if game_state_manager.players.filter(func(player: Player): return player.is_alive).is_empty():
		return true
	
	return false


func check_if_level_won(game_state_manager: GameStateManager) -> bool:
	var map = game_state_manager.map
	var enemies = game_state_manager.enemies
	var level_data = game_state_manager.level_data
	var current_turn = game_state_manager.current_turn
	var enemies_killed = game_state_manager.enemies_killed
	
	if level_data.level_type == LevelType.KILL_ENEMIES:
		assert(level_data.has('max_enemies'), 'Set max_enemies for level_type: KILL_ENEMIES')
		if enemies_killed >= level_data.max_enemies:
			return true
		
		# no alive enemies and no will spawn
		if enemies.filter(func(enemy): return enemy.is_alive).is_empty():
			var enemies_from_below_event = not level_data.level_events.filter(func(level_event): return level_event == LevelEvent.ENEMIES_FROM_BELOW).is_empty()
			if enemies_from_below_event:
				var any_event_tiles = map.tiles.any(func(tile: MapTile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('ENEMIES_FROM_BELOW_INDICATORS'))
				if (not level_data.enemies_from_below_last_turn or current_turn >= level_data.enemies_from_below_last_turn) and not any_event_tiles:
					return true
			
			var enemies_from_above_event = not level_data.level_events.filter(func(level_event): return level_event == LevelEvent.ENEMIES_FROM_ABOVE).is_empty()
			if enemies_from_above_event:
				var any_event_tiles = map.tiles.any(func(tile: MapTile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('ENEMIES_FROM_ABOVE_INDICATORS'))
				if (not level_data.enemies_from_above_last_turn or current_turn >= level_data.enemies_from_above_last_turn) and not any_event_tiles:
					return true
	
	if level_data.level_type == LevelType.SURVIVE_TURNS:
		# turn not increased yet
		if current_turn >= level_data.max_turns:
			return true
	
	return false
