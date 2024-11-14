extends Character

class_name Player

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


func _ready() -> void:
	super()
	
	#model = $Tank
	
	var arrow_model_material = StandardMaterial3D.new()
	arrow_model_material.no_depth_test = true
	arrow_model_material.disable_receive_shadows = true
	arrow_model_material.albedo_color = PLAYER_ARROW_COLOR
	
	var forced_action_model_material = StandardMaterial3D.new()
	forced_action_model_material.albedo_color = PLAYER_ARROW_COLOR
	
	# draw a player arrow on top of an enemy arrow
	# player arrow 1.2 > player sphere 1.1 > enemy arrow 1.0 > enemy sphere 0.9
	default_arrow_model.get_child(0).set_sorting_offset(1.2)
	default_arrow_model.get_child(0).set_surface_override_material(0, arrow_model_material)
	default_arrow_sphere_model.set_sorting_offset(1.1)
	default_arrow_sphere_model.set_surface_override_material(0, arrow_model_material)
	default_forced_action_model.set_surface_override_material(0, forced_action_model_material)


func spawn(spawn_tile: MapTile) -> void:
	tile = spawn_tile
	tile.set_player(self)
	
	position = Vector3(tile.position.x, 0, tile.position.z)
	
	#print('playe ' + str(tile.coords) + ' -> ' + PhaseType.keys()[current_phase] + ': ' + str(moves_per_turn) + ' MOVE(S) / ' + str(actions_per_turn) + ' ACTION(S)')


func move(tiles_path: Array[MapTile], forced: bool = false, outside_tile_position: Vector3 = Vector3.ZERO) -> void:
	if not forced and current_phase != PhaseType.MOVE:
		return
	
	await super(tiles_path, forced, outside_tile_position)
	
	var target_tile = tiles_path.back() as MapTile
	if target_tile != tile:
		if not target_tile.is_occupied():
			tile.set_player(null)
			tile = target_tile
			
			reset_tiles()
			
			# need call set_player() after reset_tiles() to properly toggle target tile
			tile.set_player(self)
			
			var duration = Global.default_speed / Global.speed
			for next_tile in tiles_path:
				if not forced:
					look_at_y(next_tile)
				
				var position_tween = create_tween()
				position_tween.tween_property(self, 'position', next_tile.position, duration).set_delay(0.1)
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


func execute_action(target_tile: MapTile) -> void:
	if current_phase != PhaseType.ACTION:
		return
	
	reset_tiles()
	
	await spawn_bullet(target_tile)
	await target_tile.get_shot(damage, action_type, action_damage, tile.coords)
	
	after_action()


func shoot(target_tile: MapTile) -> void:
	if current_phase != PhaseType.ACTION:
		return
	
	reset_tiles()
	
	await spawn_bullet(target_tile)
	await target_tile.get_shot(damage)
	
	after_action()


func after_action() -> void:
	#reset_tiles()
	
	actions_made_current_turn += 1
	
	#print('playe ' + str(tile.coords) + ' -> made action: ' + str(actions_per_turn - actions_made_current_turn) + ' more action(s) in this turn')
	
	if no_more_actions_this_turn():
		current_phase = PhaseType.WAIT
		#print('playe ' + str(tile.coords) + ' -> ' + PhaseType.keys()[current_phase])
		
		mouse_exited()
	elif not is_clicked:
		# click again if actions are available
		clicked()


func get_killed() -> void:
	super()
	print('playe ' + str(tile.coords) + ' -> dead!')
	
	tile.set_player(null)
	tile = null


func toggle_health_bar(is_toggled: bool, displayed_health: int = health) -> void:
	super(is_toggled, displayed_health)
	
	if health_bar:
		if is_toggled:
			var top_model_position = Vector3(model.global_position.x, model.global_position.y, model.global_position.z)
			health_bar.position = get_viewport().get_camera_3d().unproject_position(top_model_position)
			health_bar.position.x -= 30
			
			# hardcoded
			if is_close(get_viewport().get_camera_3d().rotation_degrees.x, -50):
				health_bar.position.y -= 50
			elif is_close(get_viewport().get_camera_3d().rotation_degrees.x, -40):
				health_bar.position.y -= 58
			else:
				health_bar.position.y -= 64


func start_turn() -> void:
	if is_alive:
		current_phase = PhaseType.MOVE
		#print('playe ' + str(tile.coords) + ' -> ' + PhaseType.keys()[current_phase] + ': ' + str(moves_per_turn) + ' MOVE(S)')
		
		moves_made_current_turn = 0
		actions_made_current_turn = 0
		
		reset_tiles()


func reset_phase() -> void:
	if is_alive:
		if current_phase == PhaseType.ACTION and not no_more_moves_this_turn():
			current_phase = PhaseType.MOVE


func reset_tiles() -> void:
	if is_clicked:
		# unclick
		clicked()
	
	mouse_exited()


func no_more_moves_this_turn() -> bool:
	if moves_made_current_turn > moves_per_turn:
		printerr('wtf?! ' + str(moves_made_current_turn) + ' ' + str(moves_per_turn))
	
	return moves_made_current_turn == moves_per_turn


func no_more_actions_this_turn() -> bool:
	if actions_made_current_turn > actions_per_turn:
		printerr('wtf?! ' + str(actions_made_current_turn) + ' ' + str(actions_per_turn))
	
	return actions_made_current_turn == actions_per_turn


func can_be_interacted_with() -> bool:
	return current_phase != PhaseType.WAIT


func can_move() -> bool:
	return current_phase == PhaseType.MOVE and state_type != StateType.MISS_MOVE


func can_make_action() -> bool:
	return current_phase == PhaseType.ACTION and state_type != StateType.MISS_ACTION


func clicked() -> void:
	if not can_be_interacted_with():
		return
	
	is_clicked = not is_clicked
	
	clicked_event.emit(self, is_clicked)
	
	if is_clicked:
		#position.y = 0.15
		toggle_outline(true)
	else:
		#position.y = 0.0
		toggle_outline(false)
		
		hovered_event.emit(self, true)


func on_mouse_entered() -> void:
	if not can_be_interacted_with():
		return
	
	if not is_clicked:
		if is_alive:
			#Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			
			hovered_event.emit(self, true)
		else:
			print('playe ' + str(tile.coords) + ' -> dead, cannot hover')


func mouse_exited() -> void:
	hovered_event.emit(self, false)


func on_mouse_exited() -> void:
	#Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	if not is_clicked:
		if is_alive:
			mouse_exited()


func on_clicked() -> void:
	if not can_be_interacted_with():
		return
	
	if is_alive:
		clicked()
	else:
		print('playe ' + str(tile.coords) + ' -> dead, cannot click')
