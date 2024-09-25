extends Character

@onready var model = $Skeleton_Head

var model_material: StandardMaterial3D
var default_arrow_model: MeshInstance3D
var default_arrow_line_model: MeshInstance3D
var planned_tile: Node3D
var order: int


func _ready():
	super()
	
	model_material = StandardMaterial3D.new()
	
	for assets_group in assets.get_children():
		if assets_group.is_in_group('ASSETS_INDICATORS'):
			for assets_child in assets_group.get_children():
				if assets_child.name == 'ArrowSign':
					default_arrow_model = assets_child
				elif assets_child.name == 'doormat':
					default_arrow_line_model = assets_child


func spawn(target_tile, new_order):
	tile = target_tile
	tile.set_enemy(self)
	
	position = Vector3(tile.position.x, 0.0, tile.position.z)
	
	order = new_order


func move(tiles_path, forced):
	if is_alive:
		if not forced and state_type == StateType.SLOW_DOWN:
			print('enemy ' + str(tile.coords) + ' -> slowed down')
			state_type = StateType.NONE
		
		var target_tile = tiles_path.back()
		if target_tile == tile:
			if forced:
				#enemy was pushed/pulled into wall
				print('enemy ' + str(tile.coords) + ' -> pushed into the wall')
				await get_shot(1, ActionType.NONE, target_tile.coords)
			else:
				print('enemy ' + str(tile.coords) + ' -> is not moving')
		else:
			if target_tile.health_type == TileHealthType.DESTRUCTIBLE or target_tile.player or target_tile.enemy or target_tile.civilian:
				get_shot(1, ActionType.NONE, target_tile.coords)
				await target_tile.get_shot(1, ActionType.NONE, target_tile.coords)
			else:
				tile.set_enemy(null)
				tile = target_tile
				tile.set_enemy(self)
				
				var duration = 0.4 / tiles_path.size()
				for next_tile in tiles_path:
					var position_tween = create_tween()
					position_tween.tween_property(self, 'position', next_tile.position, duration).set_delay(0.1)
					look_at_y(next_tile.position)
					await position_tween.finished


func plan_action(target_tile):
	clear_arrows()
	
	if planned_tile:
		planned_tile.set_planned_enemy_action(false)
		planned_tile = null
	
	if is_alive:
		planned_tile = target_tile
		planned_tile.set_planned_enemy_action(true)
		
		spawn_arrow(planned_tile)
		
		look_at_y(planned_tile.position)
		
		#print('enemy ' + str(tile.coords) + ' -> planned_tile: ' + str(planned_tile.coords))


func execute_planned_action():
	clear_arrows()
	
	var temp_planned_tile
	if planned_tile:
		# remember planned tile to be able to unset it before shooting
		temp_planned_tile = planned_tile
		planned_tile.set_planned_enemy_action(false)
		planned_tile = null
	
	if is_alive:
		if state_type == StateType.MISS_ACTION:
			print('enemy ' + str(tile.coords) + ' -> missed action')
			state_type = StateType.NONE
			return
		
		if temp_planned_tile:
			await temp_planned_tile.get_shot(damage, action_type, tile.coords)


func get_shot(taken_damage, action_type, origin_tile_coords):
	if state_type == StateType.GIVE_SHIELD:
		taken_damage = 0
		print('enemy ' + str(tile.coords) + ' -> was given shield')
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
	print('enemy ' + str(tile.coords) + ' -> dead!')
	
	clear_arrows()
	
	if planned_tile:
		planned_tile.set_planned_enemy_action(false)
		planned_tile = null
	
	tile.set_enemy(null)
	tile = null
	
	model_material.albedo_color = Color.DARK_RED


func spawn_arrow(target):
	var target_position_on_map = get_vector3_on_map(target.position - position)
	var hit_distance = Vector2i(target_position_on_map.z, target_position_on_map.x)
	var hit_direction = hit_distance.sign()
	
	var arrow_model = default_arrow_model.duplicate()
	#arrow_model.hide()
	var arrow_line_model = default_arrow_line_model.duplicate()
	#arrow_line_model.hide()
	
	arrow_model.position = get_vector3_on_map(Vector3.ZERO)
	arrow_line_model.position = get_vector3_on_map(Vector3.ZERO)
	
	# hardcoded because rotations suck
	if hit_direction == Vector2i(1, 0):
		#print('DOWN (LEFT)')
		arrow_model.rotation_degrees.y = -90
		arrow_line_model.rotation_degrees.y = -90
		#pipe-half-section.rotation_degrees.y = -180
	if hit_direction == Vector2i(-1, 0):
		#print('UP (RIGHT)')
		arrow_model.rotation_degrees.y = 90
		arrow_line_model.rotation_degrees.y = 90
		#pipe-half-section.rotation_degrees.y = 0
	if hit_direction == Vector2i(0, 1):
		#print('RIGHT (DOWN)')
		arrow_model.rotation_degrees.y = 0
		arrow_line_model.rotation_degrees.y = 0
		#pipe-half-section.rotation_degrees.y = -90
	if hit_direction == Vector2i(0, -1):
		#print('LEFT (UP)')
		arrow_model.rotation_degrees.y = 180
		arrow_line_model.rotation_degrees.y = 180
		#pipe-half-section.rotation_degrees.y = 90
	
	var position_offset = Vector3(hit_direction.y, 0, hit_direction.x)
	arrow_model.position = target_position_on_map - position_offset * 0.3
	
	add_child(arrow_model)
	
	var distance = 0.5
	while abs(hit_distance.y) > distance + 0.5 or abs(hit_distance.x) > distance + 0.5:
		arrow_line_model.position = get_vector3_on_map(position_offset * distance)
		add_child(arrow_line_model.duplicate())
		distance += 0.5


func clear_arrows():
	for child in get_children().filter(func(child): return child.is_in_group('ASSETS_ARROW')):
		child.queue_free()


func look_at_y(target_position):
	model.look_at(target_position, Vector3.UP, true)
	model.rotation_degrees.x = 0
	model.rotation_degrees.z = 0
