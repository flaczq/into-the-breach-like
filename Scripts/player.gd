extends Character

signal hovered_event(player: Node3D, is_hovered: bool)
signal clicked_event(player: Node3D, is_clicked: bool)

var moves_per_turn: int = 1
var moves_made_current_turn: int = 0
var actions_per_turn: int = 1
var actions_made_current_turn: int = 0
var current_phase: PhaseType = PhaseType.WAIT
#var is_hovered: bool = false
var is_clicked: bool = false
var is_ghost: bool = false


func _ready():
	super()
	
	#model = $Tank
	
	var arrow_model_material = StandardMaterial3D.new()
	arrow_model_material.no_depth_test = true
	arrow_model_material.disable_receive_shadows = true
	arrow_model_material.albedo_color = PLAYER_ARROW_COLOR
	
	# draw player arrow on top of enemy arrow
	# player arrow 1.2 > player sphere 1.1 > enemy arrow 1.0 > enemy sphere 0.9
	default_arrow_model.get_child(0).set_sorting_offset(1.2)
	default_arrow_model.get_child(0).set_surface_override_material(0, arrow_model_material)
	default_arrow_sphere_model.set_sorting_offset(1.1)
	default_arrow_sphere_model.set_surface_override_material(0, arrow_model_material)


func spawn(target_tile):
	tile = target_tile
	tile.set_player(self)
	
	position = Vector3(tile.position.x, 0, tile.position.z)
	
	#print('playe ' + str(tile.coords) + ' -> ' + PhaseType.keys()[current_phase] + ': ' + str(moves_per_turn) + ' MOVE(S) / ' + str(actions_per_turn) + ' ACTION(S)')


func move(tiles_path, forced = false, outside_tile = null):
	if not forced and current_phase != PhaseType.MOVE:
		return
	
	if not forced and state_type == StateType.SLOW_DOWN:
		print('playe ' + str(tile.coords) + ' -> slowed down')
		state_type = StateType.NONE
	
	var target_tile = tiles_path.back()
	if target_tile == tile:
		if forced and outside_tile:
			print('playe ' + str(tile.coords) + ' -> pushed into the wall')
			get_shot(1)
			await forced_into_occupied_tile(outside_tile, true)
		else:
			print('playe ' + str(tile.coords) + ' -> is not moving')
	else:
		if target_tile.health_type == TileHealthType.DESTRUCTIBLE or target_tile.health_type == TileHealthType.INDESTRUCTIBLE or target_tile.player or target_tile.enemy or target_tile.civilian:
			print('playe ' + str(tile.coords) + ' -> forced into (in)destructible tile or other character')
			get_shot(1)
			await forced_into_occupied_tile(target_tile)
		else:
			tile.set_player(null)
			tile = target_tile
			
			reset_tiles()
			
			# need call set_player() after reset_tiles() to properly toggle target tile
			tile.set_player(self)
			
			var duration = 0.4 / tiles_path.size()
			for next_tile in tiles_path:
				if not forced:
					look_at_y(next_tile)
				
				var position_tween = create_tween()
				position_tween.tween_property(self, 'position', next_tile.position, duration).set_delay(0.0)
				await position_tween.finished
			
			if not forced:
				moves_made_current_turn += 1
			
				#print('playe ' + str(tile.coords) + ' -> moved: ' + str(moves_per_turn - moves_made_current_turn) + ' more move(s) in this turn')
			
				if no_more_moves_this_turn():
					current_phase = PhaseType.ACTION
					#print('playe ' + str(tile.coords) + ' -> ' + PhaseType.keys()[current_phase] + ': ' + str(actions_per_turn) + ' ACTION(S)')
					
					mouse_exited()
				elif not is_clicked:
					# click again if moves are available
					clicked()


func execute_action(target_tile):
	if current_phase != PhaseType.ACTION:
		return
	
	reset_tiles()
	
	await spawn_bullet(target_tile)
	await target_tile.get_shot(damage, action_type, tile.coords)
	
	after_action()


func shoot(target_tile):
	if current_phase != PhaseType.ACTION:
		return
	
	reset_tiles()
	
	await spawn_bullet(target_tile)
	await target_tile.get_shot(damage)
	
	after_action()


func after_action():
	#reset_tiles()
	
	actions_made_current_turn += 1
	
	#print('playe ' + str(tile.coords) + ' -> made action: ' + str(actions_per_turn - actions_made_current_turn) + ' more action(s) in this turn')
	
	if no_more_actions_this_turn():
		current_phase = PhaseType.WAIT
		print('playe ' + str(tile.coords) + ' -> ' + PhaseType.keys()[current_phase])
		
		mouse_exited()
	elif not is_clicked:
		# click again if actions are available
		clicked()


func get_killed():
	super()
	print('playe ' + str(tile.coords) + ' -> dead!')
	
	tile.set_player(null)
	tile = null


func toggle_health_bar(is_toggled):
	pass
	# FIXME change to 3D, because in 2D it looks bad when moving camera
	#if health_bar:
		#if is_toggled:
			#var top_model_position = Vector3(model.global_position.x, model.global_position.y + 1.0, model.global_position.z + 0.5)
			#health_bar.position = get_viewport().get_camera_3d().unproject_position(top_model_position)
			#health_bar.show()
		#else:
			#health_bar.hide()


func start_turn():
	if is_alive:
		current_phase = PhaseType.MOVE
		#print('playe ' + str(tile.coords) + ' -> ' + PhaseType.keys()[current_phase] + ': ' + str(moves_per_turn) + ' MOVE(S)')
		
		moves_made_current_turn = 0
		actions_made_current_turn = 0
		
		reset_tiles()


func reset_phase():
	if is_alive and current_phase == PhaseType.ACTION and not no_more_moves_this_turn():
		current_phase = PhaseType.MOVE


func reset_tiles():
	if is_clicked:
		# unclick
		clicked()
	
	mouse_exited()


func reset_states():
	if is_alive:
		if state_type == StateType.MISS_ACTION:
			print('playe ' + str(tile.coords) + ' -> missed action')
			state_type = StateType.NONE


func no_more_moves_this_turn():
	if moves_made_current_turn > moves_per_turn:
		printerr('wtf?! ' + str(moves_made_current_turn) + ' ' + str(moves_per_turn))
	
	return moves_made_current_turn == moves_per_turn


func no_more_actions_this_turn():
	if actions_made_current_turn > actions_per_turn:
		printerr('wtf?! ' + str(actions_made_current_turn) + ' ' + str(actions_per_turn))
	
	return actions_made_current_turn == actions_per_turn


func can_be_interacted_with():
	return current_phase != PhaseType.WAIT and (current_phase != PhaseType.ACTION or state_type != StateType.MISS_ACTION)


func clicked():
	if not can_be_interacted_with():
		return
	
	is_clicked = not is_clicked
	
	clicked_event.emit(self, is_clicked)
	
	if is_clicked:
		#position.y = 0.15
		toggle_outline(true, PLAYER_ARROW_COLOR)
	else:
		#position.y = 0.0
		toggle_outline(false, PLAYER_ARROW_COLOR)
		
		hovered_event.emit(self, true)


func on_mouse_entered():
	if not can_be_interacted_with():
		return
	
	#if not is_hovered and not is_clicked:
	if not is_clicked:
		if is_alive:
			#Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			
			#is_hovered = true
			
			hovered_event.emit(self, true)
		else:
			print('playe ' + str(tile.coords) + ' -> dead, cannot hover')


func mouse_exited():
	#is_hovered = false
	
	hovered_event.emit(self, false)


func on_mouse_exited():
	#Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	#if is_hovered and not is_clicked:
	if not is_clicked:
		if is_alive:
			mouse_exited()


func on_clicked():
	if not can_be_interacted_with():
		return
	
	if is_alive:
		clicked()
	else:
		print('playe ' + str(tile.coords) + ' -> dead, cannot click')
