extends Util

class_name LevelManager

signal init_enemy_event(enemy_scene: int, spawn_tile: MapTile)

const SAVED_LEVELS_FILE_PATH: String	= 'res://Other/saved_levels.txt'
const TUTORIAL_LEVELS_FILE_PATH: String	= 'res://Other/tutorial_levels.txt'

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
	add_details_by_level_type(level_data)
	add_objectives(level_data)
	
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
	var indices_range = range(1, index + 1)
	if Global.save.played_maps_ids.size() < indices_range.size():
		# prevent selecting already played maps
		indices_range = indices_range.filter(func(index): return not Global.save.played_maps_ids.has(index))
		assert(not indices_range.is_empty(), 'Empty indices for selected maps')
	else:
		# clear if all maps were already played (sic!)
		Global.save.played_maps_ids.clear()
	
	var random_index = indices_range.pick_random()
	Global.save.played_maps_ids.push_back(random_index)
	print('selected level: ' + str(random_index) + prefix.substr(0, prefix.length() - 2))
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
		for selected_player in Global.save.selected_players:
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


func add_events_details(level_data: Dictionary, enemy_scenes_size: int) -> void:
	if not level_data.has('level_events'):
		return
	
	for level_event in level_data.level_events:
		# FIXME hardcoded
		if level_event == LevelEvent.ENEMIES_FROM_BELOW:
			if not level_data.has('enemies_from_below'):
				level_data.enemies_from_below = []
			
			level_data.enemies_from_below.push_back(randi_range(1, enemy_scenes_size - 1))
			level_data.enemies_from_below_first_turn = 2
			level_data.enemies_from_below_last_turn = 3
		elif level_event == LevelEvent.ENEMIES_FROM_ABOVE:
			if not level_data.has('enemies_from_above'):
				level_data.enemies_from_above = []
			
			level_data.enemies_from_above.push_back(randi_range(1, enemy_scenes_size - 1))
			level_data.enemies_from_above_first_turn = 2
			level_data.enemies_from_above_last_turn = 3
		elif level_event == LevelEvent.FALLING_MISSLE:
			level_data.falling_missle_first_turn = 2
			level_data.falling_missle_last_turn = 3
		elif level_event == LevelEvent.FALLING_ROCK:
			level_data.falling_rock_first_turn = 2
			level_data.falling_rock_last_turn = 99


func add_details_by_level_type(level_data: Dictionary) -> void:
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


func add_objectives(level_data: Dictionary) -> void:
	level_data.objectives = []
	if level_data.level_type == LevelType.TUTORIAL:
		var objective = ObjectiveObject.new()
		objective.init_by_type(LevelObjective.JUST_WIN)
		level_data.objectives.append(objective)
	elif level_data.level_type == LevelType.KILL_ENEMIES:
		var objective = ObjectiveObject.new()
		objective.init_by_type(LevelObjective.ALL_ENEMIES_DEAD)
		level_data.objectives.append(objective)
		
		# check if objective clears with .new()
		objective = ObjectiveObject.new()
		objective.init_by_type(LevelObjective.NO_PLAYERS_DEAD, true)
		level_data.objectives.append(objective)
	elif level_data.level_type == LevelType.SURVIVE_TURNS:
		var objective = ObjectiveObject.new()
		# how to set until which turn to survive
		objective.init_by_type(LevelObjective.SURVIVE_UNTIL_TURN_5)
		level_data.objectives.append(objective)
		
		objective = ObjectiveObject.new()
		objective.init_by_type(LevelObjective.NO_PLAYERS_DEAD, true)
		level_data.objectives.append(objective)
	elif level_data.level_type == LevelType.SAVE_CIVILIANS:
		var objective = ObjectiveObject.new()
		objective.init_by_type(LevelObjective.NO_CIVILIANS_DEAD)
		level_data.objectives.append(objective)
		
		objective = ObjectiveObject.new()
		objective.init_by_type(LevelObjective.NO_PLAYERS_DEAD, true)
		level_data.objectives.append(objective)
	elif level_data.level_type == LevelType.SAVE_TILES:
		var objective = ObjectiveObject.new()
		objective.init_by_type(LevelObjective.LESS_THAN_HALF_TILES_DAMAGED)
		level_data.objectives.append(objective)
		
		objective = ObjectiveObject.new()
		objective.init_by_type(LevelObjective.NO_PLAYERS_DEAD, true)
		level_data.objectives.append(objective)


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
				var event_tiles = map.get_tiles_for_events().filter(func(tile: MapTile): return tile.is_free() and not spawn_enemy_positions.has(tile.position) and spawn_enemy_positions.any(func(spawn_enemy_position): return spawn_enemy_position.distance_to(tile.position) <= 1.5))
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
				var event_tiles = map.get_tiles_for_events().filter(func(tile: MapTile): return tile.is_free() and not spawn_enemy_positions.has(tile.position) and spawn_enemy_positions.any(func(spawn_enemy_position: Vector3): return spawn_enemy_position.distance_to(tile.position) <= 1.5))
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
			assert(level_data.has('falling_missle_first_turn'), 'Set falling_missle_first_turn for level_event: FALLING_MISSLE')
			assert(level_data.has('falling_missle_last_turn'), 'Set falling_missle_last_turn for level_event: FALLING_MISSLE')
			if current_turn >= level_data.falling_missle_first_turn and current_turn <= level_data.falling_missle_last_turn:
				var event_asset = map.assets.filter(func(asset): return asset.name == 'indicator-special-cross').front().duplicate()
				var event_asset_material = StandardMaterial3D.new()
				event_asset_material.albedo_color = Color('FF0000')#red
				event_asset.set_surface_override_material(0, event_asset_material)
				
				# check if cross tiles are also proper for events
				var all_event_tiles = map.get_tiles_for_events()
				#not tile.is_occupied() and
				var event_tiles = all_event_tiles.filter(func(event_tile): return map.get_tiles_in_cross(event_tile).all(func(cross_tile): return all_event_tiles.has(cross_tile)))
				if event_tiles.is_empty():
					print('no missle indicator spawned')
					return
				
				# middle tile
				var middle_event_tile = event_tiles.pick_random()
				middle_event_tile.models.event_asset = event_asset.duplicate()
				middle_event_tile.models.event_asset.add_to_group('MISSLES_INDICATORS')
				middle_event_tile.models.event_asset.add_to_group('MIDDLE_MISSLES_INDICATORS')
				middle_event_tile.models.event_asset.show()
				middle_event_tile.add_child(middle_event_tile.models.event_asset)
				print('spawned missle at ' + str(middle_event_tile.coords))
				
				# cross tiles
				var cross_event_tiles = map.get_tiles_in_cross(middle_event_tile)
				for cross_event_tile in cross_event_tiles:
					cross_event_tile.models.event_asset = event_asset.duplicate()
					cross_event_tile.models.event_asset.add_to_group('MISSLES_INDICATORS')
					cross_event_tile.models.event_asset.add_to_group('CROSS_MISSLES_INDICATORS')
					cross_event_tile.models.event_asset.show()
					cross_event_tile.add_child(cross_event_tile.models.event_asset)
					print('spawned missles in cross at ' + str(cross_event_tile.coords))
				
				await game_state_manager.get_tree().create_timer(1.0).timeout
		# rock spawned near volcano
		elif level_event == LevelEvent.FALLING_ROCK:
			assert(level_data.has('falling_rock_first_turn'), 'Set falling_rock_first_turn for level_event: FALLING_ROCK')
			assert(level_data.has('falling_rock_last_turn'), 'Set falling_rock_last_turn for level_event: FALLING_ROCK')
			if current_turn >= level_data.falling_rock_first_turn and current_turn <= level_data.falling_rock_last_turn:
				var event_asset = map.assets.filter(func(asset): return asset.name == 'indicator-special-cross').front().duplicate()
				var event_asset_material = StandardMaterial3D.new()
				event_asset_material.albedo_color = Color('7A5134')#brown
				event_asset.set_surface_override_material(0, event_asset_material)
				
				var volcano_positions = map.tiles.filter(func(tile: MapTile): return tile.tile_type == TileType.VOLCANO).map(func(tile: MapTile): return tile.position) as Array[MapTile]
				assert(not volcano_positions.is_empty(), 'Set volcano_positions for level_event: FALLING_ROCK')
				#not tile.is_occupied() and
				var event_tiles = map.get_tiles_for_events().filter(func(tile: MapTile): return not volcano_positions.has(tile.position) and volcano_positions.any(func(volcano_position: Vector3): return volcano_position.distance_to(tile.position) <= 1.5))
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
			var event_tiles = map.tiles.filter(func(tile: MapTile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('ENEMIES_FROM_BELOW_INDICATORS') and not already_checked_enemies_tiles.has(tile))
			#if current_turn >= level_data.enemies_from_below_first_turn and current_turn <= level_data.enemies_from_below_last_turn:
			if not event_tiles.is_empty():
				var event_tile = event_tiles.front() as MapTile
				var target_character = event_tile.get_character()
				if target_character:
					already_checked_enemies_tiles.push_back(event_tile)
					await event_tile.get_shot(1)
					continue
				
				event_tile.models.event_asset.queue_free()
				event_tile.models.erase('event_asset')
				
				# TODO animation
				var spawned_enemy_scene = level_data.enemies_from_below[enemies_from_below_index]
				init_enemy_event.emit(spawned_enemy_scene, event_tile)
				enemies_from_below_index += 1
				
				# TODO check if enemy has spawned in the hole = dead already
				
				await game_state_manager.get_tree().create_timer(1.0).timeout
		# enemy spawns from above at spawned indicators - if occupied then don't spawn and try next turn
		elif level_event == LevelEvent.ENEMIES_FROM_ABOVE:
			assert(level_data.has('enemies_from_above_first_turn'), 'Set enemies_from_above_first_turn for level_event: ENEMIES_FROM_ABOVE')
			assert(level_data.has('enemies_from_above_last_turn'), 'Set enemies_from_above_last_turn for level_event: ENEMIES_FROM_ABOVE')
			assert(level_data.get('enemies_from_above'), 'Set enemies_from_above for level_event: ENEMIES_FROM_ABOVE')
			var event_tiles = map.tiles.filter(func(tile: MapTile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('ENEMIES_FROM_BELOW_INDICATORS') and not already_checked_enemies_tiles.has(tile))
			#if current_turn >= level_data.enemies_from_above_first_turn and current_turn <= level_data.enemies_from_above_last_turn:
			if not event_tiles.is_empty():
				var event_tile = event_tiles.front() as MapTile
				if not event_tile or event_tile.get_character():
					print('no event tiles or character on tile for ENEMIES_FROM_ABOVE');
					already_checked_enemies_tiles.push_back(event_tile)
					continue
				
				event_tile.models.event_asset.queue_free()
				event_tile.models.erase('event_asset')
				
				# TODO animation
				var spawned_enemy_scene = level_data.enemies_from_above[enemies_from_above_index]
				init_enemy_event.emit(spawned_enemy_scene, event_tile)
				enemies_from_above_index += 1
				
				# TODO check if enemy has spawned in the hole = dead already
				
				await game_state_manager.get_tree().create_timer(1.0).timeout
		# missle hits at spawned indicators
		elif level_event == LevelEvent.FALLING_MISSLE:
			assert(level_data.has('falling_missle_first_turn'), 'Set falling_missle_first_turn for level_event: FALLING_MISSLE')
			assert(level_data.has('falling_missle_last_turn'), 'Set falling_missle_last_turn for level_event: FALLING_MISSLE')
			#if current_turn > 1:
			# TODO add bullet spawn
			var middle_event_tile = map.tiles.filter(func(tile: MapTile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('MIDDLE_MISSLES_INDICATORS')).front()
			if middle_event_tile:
				middle_event_tile.models.event_asset.queue_free()
				middle_event_tile.models.erase('event_asset')
				# no await because there are more cross tiles
				middle_event_tile.get_shot(2)
			
			var cross_event_tiles = map.tiles.filter(func(tile: MapTile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('CROSS_MISSLES_INDICATORS'))
			if cross_event_tiles:
				var index = 1
				for cross_event_tile in cross_event_tiles:
					cross_event_tile.models.event_asset.queue_free()
					cross_event_tile.models.erase('event_asset')
					if index == cross_event_tiles.size():
						await cross_event_tile.get_shot(1)
					else:
						cross_event_tile.get_shot(1)
					index += 1
		# rock hits at spawned indicators
		elif level_event == LevelEvent.FALLING_ROCK:
			assert(level_data.has('falling_rock_first_turn'), 'Set falling_rock_first_turn for level_event: FALLING_ROCK')
			assert(level_data.has('falling_rock_last_turn'), 'Set falling_rock_last_turn for level_event: FALLING_ROCK')
			#if current_turn > 1:
			var event_tile = map.tiles.filter(func(tile: MapTile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('ROCKS_INDICATORS')).front()
			if not event_tile:
				continue
			
			event_tile.models.event_asset.queue_free()
			event_tile.models.erase('event_asset')
			# TODO add bullet spawn
			await event_tile.get_shot(1)
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
		
		# no alive enemies and none will spawn
		if not enemies.any(func(enemy): return enemy.is_alive):
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
	elif level_data.level_type == LevelType.SURVIVE_TURNS:
		# turn not increased yet
		if current_turn >= level_data.max_turns:
			return true
	
	return false


func check_objectives(game_state_manager: GameStateManager) -> void:
	var map = game_state_manager.map
	var players = game_state_manager.players
	var enemies = game_state_manager.enemies
	var civilians = game_state_manager.civilians
	var level_data = game_state_manager.level_data
	for objective in level_data.objectives:
		if objective.type == LevelObjective.JUST_WIN:
			# why does it even exist..?
			if enemies.all(func(enemy): return not enemy.is_alive):
				objective.done = true
		elif objective.type == LevelObjective.LESS_THAN_HALF_TILES_DAMAGED:
			var current_points = map.get_current_points()
			if map.origin_points / 2 > current_points:
				objective.done = true
		elif objective.type == LevelObjective.ALL_ENEMIES_DEAD:
			if enemies.all(func(enemy): return not enemy.is_alive):
				objective.done = true
		elif objective.type == LevelObjective.NO_PLAYERS_DEAD:
			if players.all(func(player): return player.is_alive):
				objective.done = true
		elif objective.type == LevelObjective.NO_CIVILIANS_DEAD:
			if civilians.all(func(civilian): return civilian.is_alive):
				objective.done = true
