extends Character

class_name Civilian


func _ready():
	super()
	
	#model = $Princess_Head


func spawn(spawn_tile):
	tile = spawn_tile
	tile.set_civilian(self)
	
	position = Vector3(tile.position.x, 0.0, tile.position.z)


func move(tiles_path, forced = false, outside_tile_position = null):
	if not forced and state_type == StateType.MISS_MOVE:
		print('civil ' + str(tile.coords) + ' -> missed move')
		state_type = StateType.NONE
		return
	
	# cannot move to INDESTRUCTIBLE_WALKABLE so any move resets this state
	if not forced and state_type == StateType.SLOW_DOWN:
		print('civil ' + str(tile.coords) + ' -> slowed down')
		state_type = StateType.NONE
	
	await super(tiles_path, forced, outside_tile_position)
	
	var target_tile = tiles_path.back()
	if target_tile != tile:
		if not target_tile.is_occupied():
			tile.set_civilian(null)
			tile = target_tile
			tile.set_civilian(self)
			
			var duration = Global.default_speed / Global.speed
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


func toggle_health_bar(is_toggled, displayed_health = health):
	super(is_toggled, displayed_health)
	
	if health_bar:
		if is_toggled:
			var top_model_position = Vector3(model.global_position.x, model.global_position.y, model.global_position.z)
			health_bar.position = get_viewport().get_camera_3d().unproject_position(top_model_position)
			
			# hardcoded
			if is_close(get_viewport().get_camera_3d().rotation_degrees.x, -50):
				health_bar.position.x -= 38
				health_bar.position.y -= 45
			elif is_close(get_viewport().get_camera_3d().rotation_degrees.x, -40):
				health_bar.position.x -= 38
				health_bar.position.y -= 50
			else:
				health_bar.position.x -= 40
				health_bar.position.y -= 55
