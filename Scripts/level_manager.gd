extends Util

signal init_enemy_event(enemy_scene: int, spawn_tile: Node3D)

const SAVED_LEVELS_FILE_PATH: String = 'res://Data/saved_levels.txt'
const TUTORIAL_LEVELS_FILE_PATH: String = 'res://Data/tutorial_levels.txt'


func generate_data(level_type, level, enemy_scenes_size, civilian_scenes_size):
	var levels_file_path = get_levels_file_path(level_type)
	var file = FileAccess.open(levels_file_path, FileAccess.READ)
	var file_content = file.get_as_text()
	var level_data_string = select_random_level_data(file_content, level, level_type)
	assert(level_data_string != file_content, 'Add level type ' + str(level_type) + ' to levels file: ' + str(levels_file_path))
	var level_data = parse_data(level_data_string)
	
	add_characters(level_data, enemy_scenes_size, civilian_scenes_size)
	add_level_type_details(level_data)
	add_events_details(level_data, enemy_scenes_size)
	
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


func select_random_level_data(file_content, level, level_type):
	var prefix = '-' + str(level) + '-' + str(level_type) + '->'
	
	if level_type == LevelType.TUTORIAL:
		return file_content.get_slice(str(level) + prefix + 'START', 1).get_slice(str(level) + prefix + 'STOP', 0)#.strip_escapes()
	
	var index = file_content.count(prefix + 'START')
	var random_index = randi_range(1, index)
	print('selected level: ' + str(random_index) + prefix)
	return file_content.get_slice(str(random_index) + prefix + 'START', 1).get_slice(str(random_index) + prefix + 'STOP', 0)#.strip_escapes()


func add_characters(level_data, enemy_scenes_size, civilian_scenes_size):
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
		for current_player_scene in Global.current_player_scenes:
			level_data.player_scenes.push_back(current_player_scene)
		
		# scene 0 is always tutorial
		# TODO pick enemies and civilians by random(?) based on level type and level number
		level_data.enemy_scenes.push_back(randi_range(1, enemy_scenes_size - 1))
		level_data.enemy_scenes.push_back(randi_range(1, enemy_scenes_size - 1))
		level_data.enemy_scenes.push_back(randi_range(1, enemy_scenes_size - 1))
		level_data.civilian_scenes.push_back(randi_range(1, civilian_scenes_size - 1))


func add_level_type_details(level_data):
	if level_data.level_type == LevelType.KILL_ENEMIES:
		# FIXME hardcoded, maybe not needed..?
		level_data.max_enemies = 7
	elif level_data.level_type == LevelType.SURVIVE_TURNS:
		# FIXME hardcoded
		level_data.max_turns = 5


func add_events_details(level_data, enemy_scenes_size):
	if not level_data.has('level_events'):
		return
	
	for level_event in level_data.level_events:
		if level_event == LevelEvent.MORE_ENEMIES:
			if not level_data.has('more_enemies'):
				level_data.more_enemies = []
			
			level_data.more_enemies.push_back(randi_range(1, enemy_scenes_size - 1))
			# FIXME hardcoded
			level_data.more_enemies_first_turn = 2
			level_data.more_enemies_last_turn = 3


func plan_events(map, level_data, current_turn):
	if not level_data.has('level_events'):
		return
	
	var more_enemies_count = level_data.level_events.filter(func(level_event): return level_event == LevelEvent.MORE_ENEMIES).size()
	for level_event in level_data.level_events:
		# enemy spawned near spawn_enemy_coords
		if level_event == LevelEvent.MORE_ENEMIES:
			if current_turn >= level_data.more_enemies_first_turn and current_turn <= level_data.more_enemies_last_turn:
				# check if some indicators were left from the last turn
				var existing_event_tiles_count = map.tiles.filter(func(tile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('MORE_ENEMIES_INDICATORS')).size()
				if existing_event_tiles_count >= more_enemies_count:
					return
				
				var event_asset = map.assets.filter(func(asset): return asset.name == 'indicator-special-cross').front().duplicate()
				var event_asset_material = StandardMaterial3D.new()
				event_asset_material.albedo_color = Color('FFFF00')#yellow
				event_asset.set_surface_override_material(0, event_asset_material)
				
				var vector2i_spawn_enemy_coords = convert_spawn_coords_to_vector_coords(level_data.spawn_enemy_coords)
				var spawn_enemy_positions = map.tiles.filter(func(tile): return vector2i_spawn_enemy_coords.has(tile.coords)).map(func(tile): return tile.position)
				var event_tiles = map.get_untargetable_tiles().filter(func(tile): return not tile.is_occupied() and not spawn_enemy_positions.has(tile.position) and spawn_enemy_positions.any(func(spawn_enemy_position): return spawn_enemy_position.distance_to(tile.position) <= 1.5))
				if event_tiles.is_empty():
					print('no more enemies indicator spawned')
					return
				
				var event_tile = event_tiles.pick_random()
				event_tile.models.event_asset = event_asset.duplicate()
				event_tile.models.event_asset.add_to_group('MORE_ENEMIES_INDICATORS')
				event_tile.models.event_asset.show()
				event_tile.add_child(event_tile.models.event_asset)
				print('more enemy at ' + str(event_tile.coords))
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
		# rock spawned near mountains
		elif level_event == LevelEvent.FALLING_ROCK:
			if current_turn > 1:
				var event_asset = map.assets.filter(func(asset): return asset.name == 'indicator-special-cross').front().duplicate()
				var event_asset_material = StandardMaterial3D.new()
				event_asset_material.albedo_color = Color('7A5134')#brown
				event_asset.set_surface_override_material(0, event_asset_material)
				
				var mountain_positions = map.tiles.filter(func(tile): return tile.tile_type == TileType.MOUNTAIN).map(func(tile): return tile.position)
				var event_tiles = map.get_untargetable_tiles().filter(func(tile): return not mountain_positions.has(tile.position) and mountain_positions.any(func(mountain_position): return mountain_position.distance_to(tile.position) <= 1.5))
				if event_tiles.is_empty():
					print('no rock indicator spawned')
					return
				
				var event_tile = event_tiles.pick_random()
				event_tile.models.event_asset = event_asset.duplicate()
				event_tile.models.event_asset.add_to_group('ROCKS_INDICATORS')
				event_tile.models.event_asset.show()
				event_tile.add_child(event_tile.models.event_asset)
				print('spawned rock at ' + str(event_tile.coords))
		#TODO more
		else:
			print('no implementation of planning level event: ' + LevelEvent.keys()[level_event])


func execute_events(map, level_data, current_turn):
	if not level_data.has('level_events'):
		return
	
	var more_enemies_index = 0
	for level_event in level_data.level_events:
		# enemy spawns at spawned indicators
		if level_event == LevelEvent.MORE_ENEMIES:
			if current_turn >= level_data.more_enemies_first_turn and current_turn <= level_data.more_enemies_last_turn:
				var event_tile = map.tiles.filter(func(tile): return not tile.is_occupied() and tile.models.get('event_asset') and tile.models.event_asset.is_in_group('MORE_ENEMIES_INDICATORS')).front()
				if not event_tile:
					return
				
				# TODO animation
				if level_data.has('more_enemies'):
					init_enemy_event.emit(level_data.more_enemies[more_enemies_index], event_tile)
				else:
					printerr('wtf?! ' + str(level_data))
					init_enemy_event.emit(0, event_tile)
				
				event_tile.models.event_asset.queue_free()
				event_tile.models.erase('event_asset')
				more_enemies_index += 1
		# missle hits at spawned indicators
		elif level_event == LevelEvent.FALLING_MISSLE:
			if current_turn > 1:
				var event_tile = map.tiles.filter(func(tile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('MISSLES_INDICATORS')).front()
				if not event_tile:
					return
				
				# TODO add bullet spawn
				await event_tile.get_shot(1)
				
				event_tile.models.event_asset.queue_free()
				event_tile.models.erase('event_asset')
		# rock hits at spawned indicators
		elif level_event == LevelEvent.FALLING_ROCK:
			if current_turn > 1:
				var event_tile = map.tiles.filter(func(tile): return tile.models.get('event_asset') and tile.models.event_asset.is_in_group('ROCKS_INDICATORS')).front()
				if not event_tile:
					return
				
				# TODO add bullet spawn
				await event_tile.get_shot(1)
				
				event_tile.models.event_asset.queue_free()
				event_tile.models.erase('event_asset')
		#TODO else...
		else: print('no implementation of executing level event: ' + LevelEvent.keys()[level_event])
