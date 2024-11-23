extends Util

class_name Character

signal action_push_back(target_character: Character, action_damage: int, origin_tile_coords: Vector2i)
signal action_pull_front(target_character: Character, action_damage: int, origin_tile_coords: Vector2i)
#signal action_miss_move(target_character: Character)
#signal action_miss_action(target_character: Character)
signal action_hit_ally(target_character: Character)
signal action_give_shield(target_character: Character)
signal action_slow_down(target_character: Character)
signal action_cross_push_back(target_character: Character, action_damage: int, origin_tile_coords: Vector2i)
signal action_indicators_cross_push_back(target_character: Character, origin_tile: MapTile, first_origin_position: Vector3)
signal collectable_picked_event(target_character: Character)

var assets_scene: Node = preload('res://Scenes/assets.tscn').instantiate()
var health_bar_scene: Node = preload('res://Scenes/health_bar.tscn').instantiate()

var is_alive: bool = true
var state_types: Array[StateType] = []
var model_outlines: Array[MeshInstance3D] = []

var id: int
var model_name: String
var model: MeshInstance3D
var default_arrow_model: Node3D
var default_arrow_sphere_model: MeshInstance3D
var default_bullet_model: MeshInstance3D
var default_forced_action_model: MeshInstance3D
var default_loot_model: MeshInstance3D
var health_bar: TextureProgressBar
var health_bar_tween: Tween
var tile: MapTile
var max_health: int
var health: int
var damage: int
var move_distance: int
var action_min_distance: int
var action_max_distance: int
var action_direction: ActionDirection
var action_type: ActionType
var action_damage: int
var passive_type: PassiveType
var can_fly: bool


func _ready() -> void:
	name = name + '_' + str(randi())
	
	# to move properly among available positions
	position = Vector3.ZERO
	
	model = get_children().filter(func(child): return child.is_visible() and child is MeshInstance3D).front()
	# make materials unique
	model.mesh.surface_set_material(0, model.get_active_material(0).duplicate())
	model.show()
	
	init_model_outlines()
	for model_outline in model_outlines:
		model_outline.hide()
	
	health_bar_scene.hide()
	
	for asset in assets_scene.get_children():
		if asset.name == 'ArrowSignContainer':
			default_arrow_model = asset
		elif asset.name == 'sphere':
			default_arrow_sphere_model = asset
			default_bullet_model = asset
		elif asset.name == 'floor-small-diagonal':
			default_forced_action_model = asset
		elif asset.name == 'crate-color':
			default_loot_model = asset


func init_model_outlines(parent: MeshInstance3D = model) -> void:
	for child in parent.get_children():
		if child.is_in_group('OUTLINES'):
			model_outlines.append(child)
		
		if child.get_child_count() > 0:
			init_model_outlines(child)


func move(tiles_path: Array[MapTile], forced: bool = false, outside_tile_position: Vector3 = Vector3.ZERO) -> void:
	toggle_health_bar(false)
	
	var target_tile = tiles_path.back() as MapTile
	if target_tile == tile:
		if forced and outside_tile_position != Vector3.ZERO:
			print('chara ' + str(tile.coords) + ' -> pushed into the wall')
			get_shot(1)
			await force_into_occupied_tile(outside_tile_position)
		else:
			print('chara ' + str(tile.coords) + ' -> is not moving')
	else:
		if target_tile.is_occupied():
			print('chara ' + str(tile.coords) + ' -> forced into (in)destructible tile or other character')
			get_shot(1)
			await force_into_occupied_tile(target_tile.position, target_tile)
		else:
			# moved out of water
			if target_tile.health_type != TileHealthType.INDESTRUCTIBLE_WALKABLE and state_types.has(StateType.MISSED_ACTION):
				print('chara ' + str(tile.coords) + ' -> reset missed action')
				state_types.erase(StateType.MISSED_ACTION)


func force_into_occupied_tile(target_tile_position: Vector3, target_tile: MapTile = null) -> void:
	# remember position to bounce back to it
	var origin_position = position
	var duration = Global.default_speed / Global.speed
	var position_tween = create_tween()
	position_tween.tween_property(self, 'position', target_tile_position, duration)
	await position_tween.finished
	
	if target_tile:
		target_tile.get_shot(1)
	
	# TODO sprite for hiting the wall
	position_tween = create_tween()
	position_tween.tween_property(self, 'position', origin_position, duration)
	await position_tween.finished


func spawn_arrow(target_tile: MapTile) -> void:
	var position_to_target = get_vector3_on_map(position - target_tile.position)
	var hit_distance = Vector2i(position_to_target.z, position_to_target.x)
	var origin_to_target_sign = hit_distance.sign()
	var hit_direction = get_hit_direction(origin_to_target_sign)
	
	var arrow_model = default_arrow_model.duplicate()
	var arrow_sphere_model = default_arrow_sphere_model.duplicate()
	
	arrow_model.position = get_vector3_on_map(Vector3.ZERO)
	arrow_sphere_model.position = get_vector3_on_map(Vector3.ZERO)
		
	# hardcoded because rotations suck b4llz
	if hit_direction == HitDirection.DOWN_LEFT:
		arrow_model.rotation_degrees.y = -90
		#arrow_sphere_model.rotation_degrees.y = -90
	elif hit_direction == HitDirection.UP_RIGHT:
		arrow_model.rotation_degrees.y = 90
		#arrow_sphere_model.rotation_degrees.y = 90
	elif hit_direction == HitDirection.RIGHT_DOWN:
		arrow_model.rotation_degrees.y = 0
		#arrow_sphere_model.rotation_degrees.y = 0
	elif hit_direction == HitDirection.LEFT_UP:
		arrow_model.rotation_degrees.y = 180
		#arrow_sphere_model.rotation_degrees.y = 180
	elif hit_direction == HitDirection.DOWN:
		arrow_model.rotation_degrees.y = -45
		#arrow_sphere_model.rotation_degrees.y = -45
	elif hit_direction == HitDirection.UP:
		arrow_model.rotation_degrees.y = 135
		#arrow_sphere_model.rotation_degrees.y = 135
	elif hit_direction == HitDirection.RIGHT:
		arrow_model.rotation_degrees.y = 45
		#arrow_sphere_model.rotation_degrees.y = 45
	elif hit_direction == HitDirection.LEFT:
		arrow_model.rotation_degrees.y = -135
		#arrow_sphere_model.rotation_degrees.y = -135
	
	var origin_position = get_vector3_on_map(Vector3.ZERO)
	var target_position = get_vector3_on_map(-1 * position_to_target)
	var position_difference = target_position - origin_position
	if action_direction == ActionDirection.HORIZONTAL_LINE or action_direction == ActionDirection.VERTICAL_LINE:
		var amount = roundi(1.5 * position_difference.length())
		if position_difference.length() > 1:
			for i in range(1, amount):
				arrow_sphere_model.position = origin_position.lerp(target_position, i / float(amount + 1.0))
				# distinguish player arrow spheres by showing them higher
				if is_in_group('PLAYERS'):
					arrow_sphere_model.position.y += 0.1
				
				arrow_sphere_model.show()
				add_child(arrow_sphere_model.duplicate())
		
		arrow_model.position = origin_position.lerp(target_position, amount / float(amount + 1.0))
		# distinguish player arrow by showing it higher
		if is_in_group('PLAYERS'):
			arrow_model.position.y += 0.1
	elif action_direction == ActionDirection.HORIZONTAL_DOT or action_direction == ActionDirection.VERTICAL_DOT:
		# bezier ftw!
		var control_1 = Vector3((position_difference / 2).x, 3.0, (position_difference / 2).z)
		var control_2 = Vector3((position_difference / 2).x, 3.0, (position_difference / 2).z)
		var amount = maxi(roundi(2 * position_difference.length()), 6)
		for i in range(1, amount):
			arrow_sphere_model.position = origin_position.bezier_interpolate(control_1, control_2, target_position, i / float(amount + 0.5))
			arrow_sphere_model.show()
			add_child(arrow_sphere_model.duplicate())
		
		# hardcoded top down
		arrow_model.rotation_degrees.z = -75
		arrow_model.position = origin_position.bezier_interpolate(control_1, control_2, target_position, amount / float(amount + 0.5))
	
	arrow_model.show()
	arrow_model.get_child(0).show()
	add_child(arrow_model)


func clear_arrows() -> void:
	for child in get_children().filter(func(child): return child.is_in_group('ARROW')):
		child.queue_free()


func toggle_arrows(is_toggled: bool) -> void:
	for child in get_children().filter(func(child): return child.is_in_group('ARROW')):
		if is_toggled:
			child.show()
		else:
			child.hide()


func spawn_action_indicators(target_tile: MapTile, origin_tile: MapTile = tile, first_origin_position: Vector3 = origin_tile.position, target_action_type: ActionType = action_type) -> void:
	var position_to_target = get_vector3_on_map(origin_tile.position - target_tile.position)
	var hit_distance = Vector2i(position_to_target.z, position_to_target.x)
	var origin_to_target_sign = hit_distance.sign()
	var hit_direction = get_hit_direction(origin_to_target_sign)
	
	# TODO more actions
	# FIXME: arrow on the floor looks bad, maybe icon near tile?
	match target_action_type:
		ActionType.NONE: pass
		ActionType.PUSH_BACK:
			#if not target_tile.is_movable():
				#return
			
			var forced_action_model = default_forced_action_model.duplicate()
			# near tile floor
			forced_action_model.position = Vector3(0, 0.1, 0)
			
			# hardcoded because rotations suck b4llz
			if hit_direction == HitDirection.DOWN_LEFT:
				forced_action_model.rotation_degrees.y = -135
			elif hit_direction == HitDirection.UP_RIGHT:
				forced_action_model.rotation_degrees.y = 45
			elif hit_direction == HitDirection.RIGHT_DOWN:
				forced_action_model.rotation_degrees.y = -45
			elif hit_direction == HitDirection.LEFT_UP:
				forced_action_model.rotation_degrees.y = 135
			elif hit_direction == HitDirection.DOWN:
				forced_action_model.rotation_degrees.y = -90
			elif hit_direction == HitDirection.UP:
				forced_action_model.rotation_degrees.y = 90
			elif hit_direction == HitDirection.RIGHT:
				forced_action_model.rotation_degrees.y = 0
			elif hit_direction == HitDirection.LEFT:
				forced_action_model.rotation_degrees.y = -180
			
			var target_position = get_vector3_on_map(-1 * position_to_target)
			forced_action_model.position = target_position + origin_tile.position - first_origin_position
			# move it at the target back
			forced_action_model.position -= 0.4 * Vector3(origin_to_target_sign.y, 0, origin_to_target_sign.x)
			forced_action_model.position.y = 0.1
			
			# make materials unique
			forced_action_model.set_surface_override_material(0, forced_action_model.get_active_material(0).duplicate())
			if target_tile.get_character():
				forced_action_model.get_active_material(0).transparency = BaseMaterial3D.Transparency.TRANSPARENCY_DISABLED
				forced_action_model.get_active_material(0).albedo_color = Color(forced_action_model.get_active_material(0).albedo_color, 1.0)
			else:
				# hide indicator a little if nothing will be pushed
				forced_action_model.get_active_material(0).transparency = BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA
				forced_action_model.get_active_material(0).albedo_color = Color(forced_action_model.get_active_material(0).albedo_color, 0.3)
			
			forced_action_model.show()
			add_child(forced_action_model)
		ActionType.PULL_FRONT:
			#if not target_tile.is_movable():
				#return
			
			var forced_action_model = default_forced_action_model.duplicate()
			# near tile floor
			forced_action_model.position = Vector3(0, 0.1, 0)
			
			# hardcoded because rotations suck b4llz
			if hit_direction == HitDirection.DOWN_LEFT:
				forced_action_model.rotation_degrees.y = 45
			elif hit_direction == HitDirection.UP_RIGHT:
				forced_action_model.rotation_degrees.y = -135
			elif hit_direction == HitDirection.RIGHT_DOWN:
				forced_action_model.rotation_degrees.y = 135
			elif hit_direction == HitDirection.LEFT_UP:
				forced_action_model.rotation_degrees.y = -45
			elif hit_direction == HitDirection.DOWN:
				forced_action_model.rotation_degrees.y = 90
			elif hit_direction == HitDirection.UP:
				forced_action_model.rotation_degrees.y = -90
			elif hit_direction == HitDirection.RIGHT:
				forced_action_model.rotation_degrees.y = -180
			elif hit_direction == HitDirection.LEFT:
				forced_action_model.rotation_degrees.y = 0
			
			# move it at the target back
			var target_position = get_vector3_on_map(-1 * position_to_target)
			forced_action_model.position = Vector3(target_position.x, 0.1, target_position.z)
			# move it at the target back
			forced_action_model.position += 0.4 * Vector3(origin_to_target_sign.y, 0, origin_to_target_sign.x)
			
			if target_tile.get_character():
				forced_action_model.get_active_material(0).transparency = BaseMaterial3D.Transparency.TRANSPARENCY_DISABLED
				forced_action_model.get_active_material(0).albedo_color = Color(forced_action_model.get_active_material(0).albedo_color, 1.0)
			else:
				# hide indicator a little if nothing will be pulled
				forced_action_model.get_active_material(0).transparency = BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA
				forced_action_model.get_active_material(0).albedo_color = Color(forced_action_model.get_active_material(0).albedo_color, 0.3)
			
			forced_action_model.show()
			add_child(forced_action_model)
		ActionType.CROSS_PUSH_BACK:
			# 'target_tile' is origin, 'origin_tile.position' is first_origin_position
			action_indicators_cross_push_back.emit(self, target_tile, origin_tile.position)
		_: pass#print('no implementation of indicator for applied action ' + ActionType.keys()[target_action_type] + ' for character ' + str(tile.coords))


func clear_action_indicators() -> void:
	for child in get_children().filter(func(child): return child.is_in_group('ACTION_INDICATORS')):
		child.queue_free()


func toggle_action_indicators(is_toggled: bool) -> void:
	for child in get_children().filter(func(child): return child.is_in_group('ACTION_INDICATORS')):
		if is_toggled:
			child.show()
		else:
			child.hide()


func spawn_bullet(target_tile: MapTile) -> void:
	var position_to_target = get_vector3_on_map(position - target_tile.position)
	var hit_distance = Vector2i(position_to_target.z, position_to_target.x)
	var origin_to_target_sign = hit_distance.sign()
	var hit_direction = get_hit_direction(origin_to_target_sign)
	
	var bullet_model = default_bullet_model.duplicate()
	
	bullet_model.position = get_vector3_on_map(Vector3.ZERO)
	
	# hardcoded because rotations suck b4llz
	if hit_direction == HitDirection.DOWN_LEFT:
		bullet_model.rotation_degrees.y = 90
	elif hit_direction == HitDirection.UP_RIGHT:
		bullet_model.rotation_degrees.y = 90
	elif hit_direction == HitDirection.RIGHT_DOWN:
		bullet_model.rotation_degrees.y = 90
	elif hit_direction == HitDirection.LEFT_UP:
		bullet_model.rotation_degrees.y = 90
	elif hit_direction == HitDirection.DOWN:
		bullet_model.rotation_degrees.y = -45
	elif hit_direction == HitDirection.UP:
		bullet_model.rotation_degrees.y = 135
	elif hit_direction == HitDirection.RIGHT:
		bullet_model.rotation_degrees.y = 45
	elif hit_direction == HitDirection.LEFT:
		bullet_model.rotation_degrees.y = -135
	
	bullet_model.show()
	add_child(bullet_model)
	
	var position_tween = create_tween()
	if action_direction == ActionDirection.HORIZONTAL_LINE or action_direction == ActionDirection.VERTICAL_LINE:
		var duration = 0.2 * position_to_target.length() / Global.speed
		position_tween.tween_property(bullet_model, 'position', get_vector3_on_map(-1 * position_to_target), duration)
	elif action_direction == ActionDirection.HORIZONTAL_DOT or action_direction == ActionDirection.VERTICAL_DOT:
		var origin_position = get_vector3_on_map(Vector3.ZERO)
		var target_position = get_vector3_on_map(-1 * position_to_target)
		var position_difference = target_position - origin_position
		var control_1 = Vector3((position_difference / 2).x, 3.0, (position_difference / 2).z)
		var control_2 = Vector3((position_difference / 2).x, 3.0, (position_difference / 2).z)
		# more = smoother
		var amount = maxi(2 * roundi(position_difference.length()), 6)
		var duration = 0.1 / Global.speed#position_difference.length() / (amount * 6.0)
		for i in range(1, amount + 1):
			# manually slowing down the bullet in the top part of the trajectory
			#var current_duration = (duration * 1.2) if (i > amount * 2/6 and i < amount * 4/6) else (duration)
			position_tween.tween_property(bullet_model, 'position', origin_position.bezier_interpolate(control_1, control_2, target_position, i / float(amount)), duration)
	await position_tween.finished
	
	bullet_model.queue_free()


func apply_action(action_type: ActionType, action_damage: int = 0, origin_tile_coords: Vector2i = Vector2i.ZERO) -> void:
	match action_type:
		ActionType.NONE: print('no applied action for character: ' + str(tile.coords))
		ActionType.PUSH_BACK: action_push_back.emit(self, action_damage, origin_tile_coords)
		ActionType.PULL_FRONT: action_pull_front.emit(self, action_damage, origin_tile_coords)
		#ActionType.MISS_MOVE: action_miss_move.emit(self)
		#ActionType.MISS_ACTION: action_miss_action.emit(self)
		ActionType.HIT_ALLY: action_hit_ally.emit(self)
		ActionType.GIVE_SHIELD: action_give_shield.emit(self)
		ActionType.SLOW_DOWN: action_slow_down.emit(self)
		ActionType.CROSS_PUSH_BACK: action_cross_push_back.emit(self, action_damage, origin_tile_coords)
		_: pass#print('no implementation of applied action: ' + ActionType.keys()[action_type] + ' for character: ' + str(self))


# not used by enemy because it's handled in move() and execute_planned_action()
func reset_states() -> void:
	if is_alive:
		# maybe reset all states..?
		if state_types.has(StateType.MISSED_MOVE):
			print('chara ' + str(tile.coords) + ' -> missed move')
			state_types.erase(StateType.MISSED_MOVE)
		elif state_types.has(StateType.MISSED_ACTION):
			print('chara ' + str(tile.coords) + ' -> missed action')
			state_types.erase(StateType.MISSED_ACTION)


func get_shot(damage: int, action_type: ActionType = ActionType.NONE, action_damage: int = 0, origin_tile_coords: Vector2i = Vector2i.ZERO) -> void:
	if state_types.has(StateType.GAVE_SHIELD):
		damage = 0
		print('chara ' + str(tile.coords) + ' -> was given shield')
		state_types.erase(StateType.GAVE_SHIELD)
	
	# reset applied planned actions for enemy target
	if is_in_group('ENEMIES'):
		var enemy: Enemy = self as Enemy
		if enemy.planned_tile:
			var target_character = enemy.planned_tile.get_character()
			if target_character:
				enemy.apply_planned_action(target_character, false)
	
	apply_action(action_type, action_damage, origin_tile_coords)
	
	if damage > 0:
		health -= damage
		set_health_bar()
		
		var color_tween = create_tween()
		color_tween.tween_property(model.get_active_material(0), 'albedo_color', model.get_active_material(0).albedo_color, 1.0).from(Color.RED)
		await color_tween.finished
		
		if health <= 0 and is_alive:
			await get_killed()
	else:
		print('chara ' + str(tile.coords) + ' -> got shot with 0 damage')
		await get_tree().create_timer(1.0).timeout


func get_killed() -> void:
	is_alive = false
	
	#model.scale.y /= 2
	#model.position.y /= 2
	
	var death_tween = create_tween().set_parallel()
	death_tween.tween_property(model, 'scale:y', 0, 0.5).from(model.scale.y)
	await death_tween.finished
	
	model.scale = Vector3.ZERO


func collect_if_collectable(target_tile: MapTile) -> void:
	var collectable = target_tile.get_collectable()
	if collectable:
		collectable.queue_free()
		
		if is_in_group('PLAYERS'):
			Global.loot_size += 1
		
		collectable_picked_event.emit(self)


# FIXME maybe too many parameters..?
func show_outline_with_predicted_health(target_tile: MapTile, tiles: Array[MapTile], origin_action_type: ActionType = action_type, origin_tile: MapTile = target_tile, damage_dealt: int = damage, next_call: bool = false) -> void:
	var target_character = target_tile.get_character()
	if target_character:
		target_character.toggle_outline(true)
		
		if target_character.state_types.has(StateType.GAVE_SHIELD):
			# FIXME show crossed shield icon
			target_character.toggle_health_bar(true)
		else:
			# include damage from hiting something after being pushed or pulled
			if origin_action_type == ActionType.PUSH_BACK or origin_action_type == ActionType.CROSS_PUSH_BACK:
				var hit_direction = (tile.coords - target_tile.coords) if (origin_tile == target_tile) else (origin_tile.coords - target_tile.coords)
				var hit_direction_sign = hit_direction.sign()
				var push_direction = -1 * hit_direction_sign
				var pushed_into_tiles = tiles.filter(func(tile: MapTile): return tile.coords == target_character.tile.coords + push_direction)
				if pushed_into_tiles.is_empty():
					# pushed outside of the map
					damage_dealt += 1
				else:
					var pushed_into_tile = pushed_into_tiles.front() as MapTile
					# pushed into other character or asset
					if pushed_into_tile.is_occupied():
						damage_dealt += 1
						# to the same for hit character as well
						target_character.show_outline_with_predicted_health(pushed_into_tile, tiles, ActionType.NONE, pushed_into_tile, 1, true)
					elif pushed_into_tile.health_type == TileHealthType.DESTROYED:
						# pushed into a hole = dead
						damage_dealt = target_character.health
			elif origin_action_type == ActionType.PULL_FRONT:
				var hit_direction = (tile.coords - target_tile.coords) if (origin_tile == target_tile) else (origin_tile.coords - target_tile.coords)
				var hit_direction_sign = hit_direction.sign()
				var pull_direction = hit_direction_sign
				var pulled_into_tiles = tiles.filter(func(tile: MapTile): return tile.coords == target_character.tile.coords + pull_direction)
				if pulled_into_tiles.is_empty():
					# pulled outside of the map
					damage_dealt += 1
				else:
					var pulled_into_tile = pulled_into_tiles.front() as MapTile
					# pulled into other character or asset
					if pulled_into_tile.is_occupied():
						damage_dealt += 1
						# to the same for hit character as well
						target_character.show_outline_with_predicted_health(pulled_into_tile, tiles, ActionType.NONE, pulled_into_tile, 1, true)
					elif pulled_into_tile.health_type == TileHealthType.DESTROYED:
						# pulled into a hole = dead
						damage_dealt = target_character.health
			
			if damage_dealt > 0:
				var predicted_health = maxi(0, target_character.health - damage_dealt)
				target_character.toggle_health_bar(true, predicted_health)
	elif next_call and target_tile.is_occupied():
		# asset exists
		target_tile.toggle_asset_outline(true)


func toggle_outline(is_toggled: bool) -> void:
	for model_outline in model_outlines:
		if is_toggled:
			var outline_color = get_character_color(self)
			model_outline.get_active_material(0).albedo_color = outline_color
			model_outline.show()
		else:
			model_outline.hide()


func init_health_bar() -> void:
	assert(max_health != null, 'Set max_health for character')
	assert(health != null, 'Set health for character')
	for child in health_bar_scene.get_children():
		if child.is_in_group('HEALTH_BAR_' + str(max_health)):
			child.show()
			health_bar = child
		else:
			child.hide()
	
	assert(health_bar, 'Health bar not found for character')
	health_bar.set_max(max_health)
	health_bar.set_value(health)
	health_bar_scene.hide()
	add_child(health_bar_scene)


func set_health_bar_value(displayed_health: int = health) -> void:
	health_bar.set_value(displayed_health)


func set_health_bar(displayed_health: int = health) -> void:
	set_health_bar_value()
	
	if health_bar_tween:
		health_bar_tween.kill()
	
	health_bar_tween = create_tween().set_loops()
	health_bar_tween.tween_callback(set_health_bar_value.bind(displayed_health)).set_delay(0.5)
	health_bar_tween.tween_callback(set_health_bar_value).set_delay(0.5)


func toggle_health_bar(is_toggled: bool, displayed_health: int = health) -> void:
	if health_bar:
		set_health_bar(displayed_health)
		
		if is_toggled:
			health_bar_scene.show()
		else:
			health_bar_scene.hide()


func reset_health_bar() -> void:
	set_health_bar_value()
	
	if health_bar_tween:
		health_bar_tween.kill()


func look_at_y(target: MapTile) -> void:
	model.look_at(target.position, Vector3.UP, true)
	model.rotation_degrees.x = 0
	model.rotation_degrees.z = 0
	# smooth rotation has bug: which side to turn by
	#var dummy = Node3D.new()
	#dummy.hide()
	#add_child(dummy)
#
	#dummy.global_transform.origin = model.global_transform.origin
	#dummy.look_at(target.position, Vector3.UP, true)
#
	#var rotation_tween = create_tween()
	#rotation_tween.tween_property(model, 'rotation_degrees:y', rotation, 0.1)
	#
	#dummy.queue_free()
