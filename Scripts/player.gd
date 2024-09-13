extends Character

signal hovered_event(player: Node3D)
signal clicked_event(player: Node3D)

@onready var model = $'ShapeCube/shape-cube'

var moves_per_turn: int = 1
var moves_made_current_turn: int = 0
var actions_per_turn: int = 1
var actions_made_current_turn: int = 0
var current_phase: PhaseType = PhaseType.WAIT
var is_hovered: bool = false
var is_clicked: bool = false


func _ready():
	# to move properly among available positions
	position = Vector3.ZERO
	
	active_material = model.get_active_material(0)


#func _input(event):
	## NEXT PHASE
	#if Input.is_key_pressed(KEY_ENTER):
		#if is_alive and is_clicked:
			#if state_type == StateType.MISS_ACTION:
				#return
			#
			#if current_phase == PhaseType.MOVE:
				#reset_tiles()
				#
				#current_phase = PhaseType.ACTION
				#print(str(tile.coords) + ' -> ' + PhaseType.keys()[current_phase] + ': ' + str(actions_per_turn) + ' ACTION(S)')
			#elif current_phase == PhaseType.ACTION:
				#reset_tiles()
				#
				#current_phase = PhaseType.WAIT
				#print(str(tile.coords) + ' -> ' + PhaseType.keys()[current_phase])
			#elif current_phase == PhaseType.WAIT:
				#print('cannot next phase, has to next turn')


func spawn(target_tile):
	tile = target_tile
	tile.set_player(self)
	
	position = Vector3(tile.position.x, 0.0, tile.position.z)
	
	#print('playe ' + str(tile.coords) + ' -> ' + PhaseType.keys()[current_phase] + ': ' + str(moves_per_turn) + ' MOVE(S) / ' + str(actions_per_turn) + ' ACTION(S)')


func move(tiles_path, forced):
	if not forced and current_phase != PhaseType.MOVE:
		return
	
	if not forced and state_type == StateType.SLOW_DOWN:
		print('playe ' + str(tile.coords) + ' -> slowed down')
		state_type = StateType.NONE
	
	var duration = 0.5 / tiles_path.size()
	for current_tile in tiles_path:
		var position_tween = create_tween()
		position_tween.tween_property(self, 'position', current_tile.position, duration).set_delay(0.1)
		await position_tween.finished
	
	tile.set_player(null)
	tile = tiles_path.back()
	
	reset_tiles()
	
	# need call set_player() after reset_tiles() to properly toggle target tile
	tile.set_player(self)
	
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


func after_action():
	reset_tiles()
	
	actions_made_current_turn += 1
	
	#print('playe ' + str(tile.coords) + ' -> made action: ' + str(actions_per_turn - actions_made_current_turn) + ' more action(s) in this turn')
	
	if no_more_actions_this_turn():
		current_phase = PhaseType.WAIT
		print('playe ' + str(tile.coords) + ' -> ' + PhaseType.keys()[current_phase])
		
		mouse_exited()
	elif not is_clicked:
		# click again if actions are available
		clicked()


func execute_action(target_tile):
	if current_phase != PhaseType.ACTION:
		return
	
	await target_tile.get_shot(0, action_type, tile.coords)
	
	after_action()


func shoot(target_tile):
	if current_phase != PhaseType.ACTION:
		return
	
	await target_tile.get_shot(damage, ActionType.NONE, tile.coords)
	
	after_action()


func get_shot(taken_damage, action_type, origin_tile_coords):
	if state_type == StateType.GIVE_SHIELD:
		taken_damage = 0
		print('playe ' + str(tile.coords) + ' -> was given shield')
		state_type = StateType.NONE
	
	health -= taken_damage
	
	apply_action_type(action_type, origin_tile_coords)
	
	var color_tween = create_tween()
	color_tween.tween_property(active_material, 'albedo_color', active_material.albedo_color, 1.0).from(Color.RED)
	await color_tween.finished
	
	if health <= 0 and is_alive:
		is_alive = false
		print('playe ' + str(tile.coords) + ' -> dead!')
		
		tile.set_player(null)
		tile = null
		
		active_material.albedo_color = Color.DARK_RED


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
		printerr('wtf?!' + ' ' + str(moves_made_current_turn) + ' ' + str(moves_per_turn))
	
	return moves_made_current_turn == moves_per_turn


func no_more_actions_this_turn():
	if actions_made_current_turn > actions_per_turn:
		printerr('wtf?!' + ' ' + str(actions_made_current_turn) + ' ' + str(actions_per_turn))
	
	return actions_made_current_turn == actions_per_turn


func can_be_interacted_with():
	return current_phase != PhaseType.WAIT and (current_phase != PhaseType.ACTION or state_type != StateType.MISS_ACTION)


func clicked():
	if not can_be_interacted_with():
		return
	
	is_clicked = not is_clicked
	
	clicked_event.emit(self)
	
	# FIXME
	if is_clicked:
		rotation_degrees.y = 45.0
	else:
		rotation_degrees.y = 0.0
		
		hovered_event.emit(self)


func on_mouse_entered():
	if not can_be_interacted_with():
		return
	
	if not is_hovered and not is_clicked:
		if is_alive:
			#Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			
			is_hovered = true
			
			hovered_event.emit(self)
		else:
			print('playe ' + str(tile.coords) + ' -> dead, cannot hover')


func mouse_exited():
	is_hovered = false
	
	hovered_event.emit(self)


func on_mouse_exited():
	#Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	if is_hovered and not is_clicked:
		if is_alive:
			mouse_exited()


func on_clicked():
	if not can_be_interacted_with():
		return
	
	if is_alive:
		clicked()
	else:
		print('playe ' + str(tile.coords) + ' -> dead, cannot click')
