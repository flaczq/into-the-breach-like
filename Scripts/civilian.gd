extends Character


func _ready():
	super()
	
	#model = $Princess_Head


func spawn(target_tile):
	tile = target_tile
	tile.set_civilian(self)
	
	position = Vector3(tile.position.x, 0.0, tile.position.z)


func move(tiles_path, forced = false, outside_tile = null):
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
			if forced and outside_tile:
				print('civil ' + str(tile.coords) + ' -> pushed into the wall')
				get_shot(1)
				await forced_into_occupied_tile(outside_tile, true)
			else:
				print('civil ' + str(tile.coords) + ' -> is not moving')
		else:
			if target_tile.health_type == TileHealthType.DESTRUCTIBLE or target_tile.health_type == TileHealthType.INDESTRUCTIBLE or target_tile.player or target_tile.enemy or target_tile.civilian:
				print('civil ' + str(tile.coords) + ' -> forced into (in)destructible tile or other character')
				get_shot(1)
				await forced_into_occupied_tile(target_tile)
			else:
				tile.set_civilian(null)
				tile = target_tile
				tile.set_civilian(self)
				
				var duration = 0.4 / tiles_path.size()
				for next_tile in tiles_path:
					if not forced:
						look_at_y(next_tile)
					
					var position_tween = create_tween()
					position_tween.tween_property(self, 'position', next_tile.position, duration).set_delay(0.1)
					await position_tween.finished


func get_killed():
	super()
	print('civil ' + str(tile.coords) + ' -> dead!')
	
	tile.set_civilian(null)
	tile = null


func toggle_health_bar(is_toggled):
	super(is_toggled)
	
	if health_bar:
		if is_toggled:
			var top_model_position = Vector3(model.global_position.x, model.global_position.y, model.global_position.z)
			health_bar.position = get_viewport().get_camera_3d().unproject_position(top_model_position)
			health_bar.position.x -= 33
			
			# hardcoded
			if is_close(get_viewport().get_camera_3d().rotation_degrees.x, -50):
				health_bar.position.y -= 50
			elif is_close(get_viewport().get_camera_3d().rotation_degrees.x, -40):
				health_bar.position.y -= 57
			else:
				health_bar.position.y -= 61
