extends Character

@onready var model = $'AnimalDog/animal-dog/root/torso'


func _ready():
	# to move properly among available positions
	position = Vector3.ZERO
	
	active_material = model.get_active_material(0)


func spawn(target_tile):
	tile = target_tile
	tile.set_civilian(self)
	
	position = Vector3(tile.position.x, 0.0, tile.position.z)


func move(tiles_path, forced):
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
				#civilian was pushed/pulled into wall
				await get_shot(1, ActionType.NONE, target_tile.coords)
			else:
				print('civil ' + str(tile.coords) + ' -> is not moving')
		else:
			if target_tile.player or target_tile.enemy or target_tile.civilian:
				get_shot(1, ActionType.NONE, target_tile.coords)
				await target_tile.get_shot(1, ActionType.NONE, target_tile.coords)
			else:
				tile.set_civilian(null)
				tile = target_tile
				tile.set_civilian(self)
				
				var duration = 0.4 / tiles_path.size()
				for current_tile in tiles_path:
					var position_tween = create_tween()
					position_tween.tween_property(self, 'position', current_tile.position, duration).set_delay(0.1)
					await position_tween.finished


func get_shot(taken_damage, action_type, origin_tile_coords):
	if state_type == StateType.GIVE_SHIELD:
		taken_damage = 0
		print('civil ' + str(tile.coords) + ' -> was given shield')
		state_type = StateType.NONE
	
	health -= taken_damage
	
	apply_action_type(action_type, origin_tile_coords)
	
	var color_tween = create_tween()
	color_tween.tween_property(active_material, 'albedo_color', active_material.albedo_color, 1.0).from(Color.RED)
	await color_tween.finished
	
	if health <= 0 and is_alive:
		get_killed()


func get_killed():
	is_alive = false
	print('civil ' + str(tile.coords) + ' -> dead!')
	
	tile.set_civilian(null)
	tile = null
	
	active_material.albedo_color = Color.DARK_RED
