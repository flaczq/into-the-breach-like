extends Character


func _ready():
	super()
	
	model = $Princess_Head


func spawn(target_tile):
	tile = target_tile
	tile.set_civilian(self)
	
	position = Vector3(tile.position.x, 0.0, tile.position.z)


func move(tiles_path, forced, outside_tile):
	if is_alive:
		if not forced and state_type == StateType.MISS_ACTION:
			print('civil ' + str(tile.coords) + ' -> missed action=move')
			state_type = StateType.NONE
			return
		
		if not forced and state_type == StateType.SLOW_DOWN:
			print('civil ' + str(tile.coords) + ' -> slowed down')
			state_type = StateType.NONE
		
		var target_tile = tiles_path.back()
		if target_tile == tile:
			if forced:
				print('civil ' + str(tile.coords) + ' -> pushed into the wall')
				await forced_into_occupied_tile(outside_tile, true)
			else:
				print('civil ' + str(tile.coords) + ' -> is not moving')
		else:
			if target_tile.health_type == TileHealthType.DESTRUCTIBLE or target_tile.player or target_tile.enemy or target_tile.civilian:
				print('civil ' + str(tile.coords) + ' -> forced into other character or destructible tile')
				get_shot(1, ActionType.NONE, target_tile.coords)
	
				await forced_into_occupied_tile(target_tile, false)
			else:
				tile.set_civilian(null)
				tile = target_tile
				tile.set_civilian(self)
				
				var duration = 0.4 / tiles_path.size()
				for next_tile in tiles_path:
					if not forced:
						look_at_y(next_tile.position)
					
					var position_tween = create_tween()
					position_tween.tween_property(self, 'position', next_tile.position, duration).set_delay(0.1)
					await position_tween.finished


func get_shot(taken_damage, action_type, origin_tile_coords):
	if state_type == StateType.GIVE_SHIELD:
		taken_damage = 0
		print('civil ' + str(tile.coords) + ' -> was given shield')
		state_type = StateType.NONE
	
	health -= taken_damage
	
	apply_action_type(action_type, origin_tile_coords)
	
	model.set_surface_override_material(0, model_material)
	var color_tween = create_tween()
	color_tween.tween_property(model_material, 'albedo_color', model_material.albedo_color, 1.0).from(Color.RED)
	await color_tween.finished
	model.set_surface_override_material(0, null)
	
	if health <= 0 and is_alive:
		get_killed()


func get_killed():
	is_alive = false
	print('civil ' + str(tile.coords) + ' -> dead!')
	
	tile.set_civilian(null)
	tile = null
	
	model_material.albedo_color = Color.DARK_RED
