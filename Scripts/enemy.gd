extends Character

const FLASHING_SHADER: Resource = preload('res://Other/flashing_shader.gdshader')


var arrow_model_material: StandardMaterial3D
var arrow_shader_material: ShaderMaterial
var planned_tile: Node3D
var order: int
var highlight_tween: Tween


func _ready():
	super()
	
	#model = $Skeleton_Head
	
	arrow_model_material = StandardMaterial3D.new()
	arrow_model_material.no_depth_test = true
	arrow_model_material.disable_receive_shadows = true
	arrow_model_material.albedo_color = ENEMY_ARROW_COLOR
	
	arrow_shader_material = ShaderMaterial.new()
	arrow_shader_material.set_shader(FLASHING_SHADER)
	
	default_arrow_model.get_child(0).set_surface_override_material(0, arrow_model_material)
	default_arrow_sphere_model.set_surface_override_material(0, arrow_model_material)


func spawn(target_tile, new_order):
	tile = target_tile
	tile.set_enemy(self)
	
	position = Vector3(tile.position.x, 0.0, tile.position.z)
	
	order = new_order


func move(tiles_path, forced = false, outside_tile = null):
	toggle_arrows(false)
	
	if is_alive:
		if not forced and state_type == StateType.SLOW_DOWN:
			print('enemy ' + str(tile.coords) + ' -> slowed down')
			state_type = StateType.NONE
		
		var target_tile = tiles_path.back()
		if target_tile == tile:
			if forced and outside_tile:
				print('enemy ' + str(tile.coords) + ' -> pushed into the wall')
				await forced_into_occupied_tile(outside_tile, true)
			else:
				print('enemy ' + str(tile.coords) + ' -> is not moving')
		else:
			if target_tile.health_type == TileHealthType.DESTRUCTIBLE or target_tile.player or target_tile.enemy or target_tile.civilian:
				print('enemy ' + str(tile.coords) + ' -> pushed into other character or destructible tile')
				get_shot(1)
				
				await forced_into_occupied_tile(target_tile)
			else:
				#if forced:
				clear_arrows()
				
				tile.set_enemy(null)
				tile = target_tile
				tile.set_enemy(self)
				
				var duration = 0.4 / tiles_path.size()
				for next_tile in tiles_path:
					if not forced:
						look_at_y(next_tile)
					
					var position_tween = create_tween()
					position_tween.tween_property(self, 'position', next_tile.position, duration).set_delay(0.1)
					await position_tween.finished
	
	toggle_arrows(true)


func plan_action(target_tile):
	if planned_tile != target_tile:
		reset_planned_tile()
		
		if is_alive:
			planned_tile = target_tile
			planned_tile.set_planned_enemy_action(true)
			
			spawn_arrow(planned_tile)
			
			look_at_y(planned_tile)
			
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
			await spawn_bullet(temp_planned_tile)
			
			await temp_planned_tile.get_shot(damage, action_type, tile.coords)


func get_killed():
	is_alive = false
	print('enemy ' + str(tile.coords) + ' -> dead!')
	
	reset_planned_tile()
	
	tile.set_enemy(null)
	tile = null
	
	model.get_active_material(0).albedo_color = Color.DARK_RED


func reset_planned_tile():
	clear_arrows()
	
	if planned_tile:
		planned_tile.set_planned_enemy_action(false)
		planned_tile = null


func toggle_arrow_highlight(is_toggled):
	# MAYBE show arrows only when hovered
	#for child in get_children().filter(func(child): return child.is_in_group('ASSETS_ARROW') and child.name != 'ArrowSignContainer'):
		#if is_toggled:
			#child.show()
		#else:
			#child.hide()
	
	if highlight_tween:
		highlight_tween.kill()
	
	if is_toggled:
		highlight_tween = create_tween().set_loops()
		highlight_tween.tween_property(arrow_model_material, 'albedo_color', ENEMY_ARROW_HIGHLIGHTED_COLOR, 0.3)
		highlight_tween.tween_interval(0.1)
		highlight_tween.tween_property(arrow_model_material, 'albedo_color', ENEMY_ARROW_COLOR, 0.3)
		#arrow_model_material.albedo_color = Color.YELLOW
		#arrow_model_material.set_next_pass(arrow_shader_material)
	else:
		arrow_model_material.albedo_color = ENEMY_ARROW_COLOR
		#arrow_model_material.set_next_pass(null)
