extends Character

class_name Civilian

var id: CivilianType


func _ready() -> void:
	super()
	
	#model = $Princess_Head


func after_ready() -> void:
	super()


func spawn(spawn_tile: MapTile) -> void:
	tile = spawn_tile
	tile.set_civilian(self)
	
	position = Vector3(tile.position.x, 0.0, tile.position.z)


func move(tiles_path: Array[MapTile], forced: bool = false, outside_tile_position: Vector3 = Vector3.ZERO) -> void:
	if not forced and state_types.has(StateType.MISSED_MOVE):
		print('civil ' + str(tile.coords) + ' -> missed move')
		state_types.erase(StateType.MISSED_MOVE)
		return
	
	# cannot move to INDESTRUCTIBLE_WALKABLE so any move resets this state
	if not forced and state_types.has(StateType.SLOWED_DOWN):
		print('civil ' + str(tile.coords) + ' -> slowed down')
		state_types.erase(StateType.SLOWED_DOWN)
	
	# can get killed here
	await super(tiles_path, forced, outside_tile_position)
	
	if not is_alive:
		return
	
	var target_tile = tiles_path.back() as MapTile
	if target_tile != tile:
		if not target_tile.is_occupied():
			tile.set_civilian(null)
			tile = target_tile
			tile.set_civilian(self)
			
			var duration = Global.move_speed / Global.default_speed
			for next_tile in tiles_path:
				if not forced:
					look_at_y(next_tile)
				
				var position_tween = create_tween()
				position_tween.tween_property(self, 'position', next_tile.position, duration).set_delay(0.0)
				await position_tween.finished
			
			collect_if_collectable(target_tile)


func get_killed() -> void:
	super()
	print('civil ' + str(tile.coords) + ' -> dead!')
	
	tile.set_civilian(null)
	tile = null


func toggle_health_bar(is_toggled: bool, displayed_health: int = health) -> void:
	super(is_toggled, displayed_health)
	
	if health_bar:
		if is_toggled:
			var top_model_position = Vector3(model.global_position.x, model.global_position.y, model.global_position.z)
			health_bar.position = get_viewport().get_camera_3d().unproject_position(top_model_position)
			
			# hardcoded
			if Global.camera_position == CameraPosition.HIGH:
				health_bar.position.x -= 38
				health_bar.position.y -= 45
			elif Global.camera_position == CameraPosition.MIDDLE:
				health_bar.position.x -= 38
				health_bar.position.y -= 50
			elif Global.camera_position == CameraPosition.LOW:
				health_bar.position.x -= 40
				health_bar.position.y -= 55
