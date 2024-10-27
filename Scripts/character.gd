extends Util

class_name Character

signal action_push_back(target_character: Character, action_damage: int, origin_tile_coords: Vector2i)
signal action_pull_front(target_character: Character, action_damage: int, origin_tile_coords: Vector2i)
signal action_miss_action(target_character: Character)
signal action_hit_ally(target_character: Character)
signal action_give_shield(target_character: Character)
signal action_slow_down(target_character: Character)
signal action_cross_push_back(target_character: Character, action_damage: int, origin_tile_coords: Vector2i)

@export var assets_scene: PackedScene

@onready var health_bar = $HealthProgressBar

var is_alive: bool = true
var state_type: StateType = StateType.NONE
var model_outlines: Array[Node] = []

var model_name: String
var model: MeshInstance3D
var default_arrow_model: Node3D
var default_arrow_sphere_model: MeshInstance3D
var default_bullet_model: MeshInstance3D
var default_forced_action_model: MeshInstance3D
var max_health: int
var health: int
var damage: int
var move_distance: int
var action_min_distance: int
var action_max_distance: int
var action_direction: ActionDirection
var action_type: ActionType
var action_damage: int
var can_fly: bool
var tile: Node3D
var health_bar_tween: Tween


func _ready():
	name = name + '_' + str(randi())
	
	# to move properly among available positions
	position = Vector3.ZERO
	
	model = get_children().filter(func(child): return child.is_visible() and child is MeshInstance3D).front()
	# make materials unique
	model.mesh.surface_set_material(0, model.get_active_material(0).duplicate())
	model.show()
	
	set_model_outlines()
	for model_outline in model_outlines:
		model_outline.hide()
	
	health_bar.hide()
	
	var assets_instance = assets_scene.instantiate()
	for asset in assets_instance.get_children():
		if asset.name == 'ArrowSignContainer':
			default_arrow_model = asset
		elif asset.name == 'sphere':
			default_arrow_sphere_model = asset
			default_bullet_model = asset
		elif asset.name == 'floor-small-diagonal':
			default_forced_action_model = asset


func set_model_outlines(parent = model):
	for child in parent.get_children():
		if child.is_in_group('OUTLINES'):
			model_outlines.append(child)
		
		if child.get_child_count() > 0:
			set_model_outlines(child)


func force_into_occupied_tile(target_tile, is_outside = false):
	# remember position to bounce back to it
	var origin_position = position
	var duration = 0.4
	var position_tween = create_tween()
	position_tween.tween_property(self, 'position', target_tile.position, duration)
	await position_tween.finished
	
	if not is_outside:
		target_tile.get_shot(1)
	
	# TODO hit the wall sprite
	position_tween = create_tween()
	position_tween.tween_property(self, 'position', origin_position, duration)
	await position_tween.finished


func spawn_arrow(target):
	var position_to_target = get_vector3_on_map(position - target.position)
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


func clear_arrows():
	for child in get_children().filter(func(child): return child.is_in_group('ARROW')):
		child.queue_free()


func toggle_arrows(is_toggled):
	for child in get_children().filter(func(child): return child.is_in_group('ARROW')):
		if is_toggled:
			child.show()
		else:
			child.hide()


func spawn_action_indicators(target_tile, origin_tile = tile, first_origin_position = origin_tile.position, target_action_type = action_type):
	var position_to_target = get_vector3_on_map(origin_tile.position - target_tile.position)
	var hit_distance = Vector2i(position_to_target.z, position_to_target.x)
	var origin_to_target_sign = hit_distance.sign()
	var hit_direction = get_hit_direction(origin_to_target_sign)
	
	# TODO more actions
	# FIXME: arrow on the floor looks bad, maybe icon near tile?
	match target_action_type:
		ActionType.NONE: pass
		ActionType.PUSH_BACK:
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
			forced_action_model.position -= 0.3 * Vector3(origin_to_target_sign.y, 0, origin_to_target_sign.x)
			forced_action_model.position.y = 0.1
			
			# make materials unique
			forced_action_model.set_surface_override_material(0, forced_action_model.get_active_material(0).duplicate())
			if target_tile.get_character():
				forced_action_model.get_active_material(0).transparency = BaseMaterial3D.Transparency.TRANSPARENCY_DISABLED
				forced_action_model.get_active_material(0).albedo_color = Color(forced_action_model.get_active_material(0).albedo_color, 1.0)
			else:
				# hide indicator a little if nothing will be pushed
				forced_action_model.get_active_material(0).transparency = BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA
				forced_action_model.get_active_material(0).albedo_color = Color(forced_action_model.get_active_material(0).albedo_color, 0.5)
			
			forced_action_model.show()
			add_child(forced_action_model)
		ActionType.PULL_FRONT:
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
			forced_action_model.position += 0.3 * Vector3(origin_to_target_sign.y, 0, origin_to_target_sign.x)
			
			if target_tile.get_character():
				forced_action_model.get_active_material(0).transparency = BaseMaterial3D.Transparency.TRANSPARENCY_DISABLED
				forced_action_model.get_active_material(0).albedo_color = Color(forced_action_model.get_active_material(0).albedo_color, 1.0)
			else:
				# hide indicator a little if nothing will be pulled
				forced_action_model.get_active_material(0).transparency = BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA
				forced_action_model.get_active_material(0).albedo_color = Color(forced_action_model.get_active_material(0).albedo_color, 0.5)
			
			forced_action_model.show()
			add_child(forced_action_model)
		ActionType.CROSS_PUSH_BACK:
			# FIXME maybe don't search for map here..?
			var map = get_parent().get_children().filter(func(child): return child.is_in_group('MAPS')).front()
			for current_tile in map.tiles:
				if is_tile_adjacent_by_coords(target_tile.coords, current_tile.coords):
					# 'current_tile' is target, 'target_tile' is origin, 'origin_tile.position' is first_origin_position
					spawn_action_indicators(current_tile, target_tile, origin_tile.position, ActionType.PUSH_BACK)
		_: print('no implementation of indicator for applied action ' + ActionType.keys()[target_action_type] + ' for character ' + str(tile.coords))


func clear_action_indicators():
	for child in get_children().filter(func(child): return child.is_in_group('ACTION_INDICATORS')):
		child.queue_free()


func toggle_action_indicators(is_toggled):
	for child in get_children().filter(func(child): return child.is_in_group('ACTION_INDICATORS')):
		if is_toggled:
			child.show()
		else:
			child.hide()


func spawn_bullet(target):
	var position_to_target = get_vector3_on_map(position - target.position)
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
		var duration = position_to_target.length() / 12.0
		position_tween.tween_property(bullet_model, 'position', get_vector3_on_map(-1 * position_to_target), duration)
	else:
		var origin_position = get_vector3_on_map(Vector3.ZERO)
		var target_position = get_vector3_on_map(-1 * position_to_target)
		var position_difference = target_position - origin_position
		var control_1 = Vector3((position_difference / 2).x, 3.0, (position_difference / 2).z)
		var control_2 = Vector3((position_difference / 2).x, 3.0, (position_difference / 2).z)
		# more = smoother
		var amount = maxi(2 * roundi(position_difference.length()), 6)
		var duration = position_difference.length() / (amount * 10.0)
		for i in range(1, amount + 1):
			# manually slowing down the bullet in the top part of the trajectory
			var current_duration = (duration * 1.2) if (i > amount * 2/6 and i < amount * 4/6) else (duration)
			position_tween.tween_property(bullet_model, 'position', origin_position.bezier_interpolate(control_1, control_2, target_position, i / float(amount)), current_duration)
	await position_tween.finished
	
	bullet_model.queue_free()


func apply_action(action_type, action_damage = 0, origin_tile_coords = null):
	match action_type:
		ActionType.NONE: print('no applied action for character: ' + str(self))
		ActionType.PUSH_BACK: action_push_back.emit(self, action_damage, origin_tile_coords)
		ActionType.PULL_FRONT: action_pull_front.emit(self, action_damage, origin_tile_coords)
		ActionType.MISS_ACTION: action_miss_action.emit(self)
		ActionType.HIT_ALLY: action_hit_ally.emit(self)
		ActionType.GIVE_SHIELD: action_give_shield.emit(self)
		ActionType.SLOW_DOWN: action_slow_down.emit(self)
		ActionType.CROSS_PUSH_BACK: action_cross_push_back.emit(self, action_damage, origin_tile_coords)
		_: print('no implementation of applied action: ' + ActionType.keys()[action_type] + ' for character: ' + str(self))


func get_shot(damage, action_type = ActionType.NONE, action_damage = 0, origin_tile_coords = null):
	if state_type == StateType.GIVE_SHIELD:
		damage = 0
		print('chara ' + str(tile.coords) + ' -> was given shield')
		state_type = StateType.NONE
	
	apply_action(action_type, action_damage, origin_tile_coords)
	
	if damage > 0:
		health -= damage
		set_health_bar()
		
		var color_tween = create_tween()
		color_tween.tween_property(model.get_active_material(0), 'albedo_color', model.get_active_material(0).albedo_color, 1.0).from(Color.RED)
		await color_tween.finished
		
		if health <= 0 and is_alive:
			get_killed()
	else:
		print('chara ' + str(tile.coords) + ' -> got shot with 0 damage')


func get_killed():
	is_alive = false
	
	model.scale.y /= 2
	model.position.y /= 2


func toggle_outline(is_toggled, outline_color = Color.BLACK):
	for model_outline in model_outlines:
		if is_toggled:
			model_outline.get_active_material(0).albedo_color = outline_color
			model_outline.show()
		else:
			model_outline.hide()


func toggle_health_bar(is_toggled, displayed_health = health):
	if health_bar:
		set_health_bar(displayed_health)
		
		if is_toggled:
			health_bar.show()
		else:
			health_bar.hide()


func set_health_bar_value(displayed_health = health):
	health_bar.set_value(displayed_health)


func set_health_bar(displayed_health = health):
	health_bar.set_max(max_health)
	set_health_bar_value(displayed_health)
	
	if health_bar_tween:
		health_bar_tween.kill()
	
	if displayed_health != health:
		health_bar_tween = create_tween().set_loops()
		health_bar_tween.tween_callback(set_health_bar_value).set_delay(0.5)
		health_bar_tween.tween_callback(set_health_bar_value.bind(displayed_health)).set_delay(0.5)
	
	# FIXME hacky wacky health bar segments
	if health_bar.get_child_count() > 0:
		if max_health == 1:
			health_bar.get_child(0).text = ''
		elif max_health == 2:
			health_bar.get_child(0).text = '|'
		elif max_health == 3:
			health_bar.get_child(0).text = '|       |'
		elif max_health == 4:
			health_bar.get_child(0).text = '|     |     |'


func reset_health_bar():
	set_health_bar_value()
	
	if health_bar_tween:
		health_bar_tween.kill()


func look_at_y(target):
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
