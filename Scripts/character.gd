extends Util

class_name Character

@export var assets_scene: PackedScene

signal action_push_back(character: Character, origin_tile_coords: Vector2i)
signal action_pull_front(character: Character, origin_tile_coords: Vector2i)
signal action_miss_action(character: Character)
signal action_hit_ally(character: Character)
signal action_give_shield(character: Character)
signal action_slow_down(character: Character)

var is_alive: bool = true
var state_type: StateType = StateType.NONE

var model: Node3D
var model_material: StandardMaterial3D
var default_arrow_model: Node3D
var default_arrow_sphere_model: MeshInstance3D
var default_bullet_model: Node3D
var health: int
var damage: int
var move_distance: int
var can_fly: bool
var action_direction: ActionDirection
var action_type: ActionType
var action_distance: int
var tile: Node3D


func _ready():
	name = name + '_' + str(randi())
	
	# to move properly among available positions
	position = Vector3.ZERO
	
	model = get_children().filter(func(child): return child.is_visible() and child is MeshInstance3D).front()
	model_material = StandardMaterial3D.new()
	
	var assets_instance = assets_scene.instantiate()
	for asset in assets_instance.get_children():
		if asset.name == 'ArrowSignContainer':
			default_arrow_model = asset
		elif asset.name == 'sphere':
			default_arrow_sphere_model = asset
			default_bullet_model = asset
		#elif asset.name == 'sphere':
			#default_bullet_model = asset


func init(character_init_data):
	#model = get_node(character_init_data.model_path)
	health = character_init_data.health
	damage = character_init_data.damage
	move_distance = character_init_data.move_distance
	can_fly = character_init_data.can_fly
	action_direction = character_init_data.action_direction
	action_type = character_init_data.action_type
	action_distance = character_init_data.action_distance


func apply_action_type(action_type, origin_tile_coords):
	match action_type:
		ActionType.PUSH_BACK: action_push_back.emit(self, origin_tile_coords)
		ActionType.PULL_FRONT: action_pull_front.emit(self, origin_tile_coords)
		ActionType.MISS_ACTION: action_miss_action.emit(self)
		ActionType.HIT_ALLY: action_hit_ally.emit(self)
		ActionType.GIVE_SHIELD: action_give_shield.emit(self)
		ActionType.SLOW_DOWN: action_slow_down.emit(self)
		_: print('no action')


func forced_into_occupied_tile(target_tile, is_outside):
	# remember position to bounce back to
	var origin_position = position
	var duration = 0.4
	var position_tween = create_tween()
	position_tween.tween_property(self, 'position', target_tile.position, duration)
	await position_tween.finished
	
	if not is_outside:
		target_tile.get_shot(1, ActionType.NONE, target_tile.coords)
	
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
	
	var position_offset = Vector3(origin_to_target_sign.y, 0, origin_to_target_sign.x)
	var arrow_model_position = get_vector3_on_map(position_offset * 0.5 - position_to_target)
	if action_direction == ActionDirection.HORIZONTAL_LINE or action_direction == ActionDirection.VERTICAL_LINE:
		# bezier ftw!
		var origin_position = get_vector3_on_map(Vector3.ZERO)
		var target_position = get_vector3_on_map(-1 * position_to_target)
		var position_difference = target_position - origin_position
		var amount = maxi(1 * roundi(position_difference.length()), 2)
		if position_difference.length() > 1:
			for i in range(1, amount):
				arrow_sphere_model.position = origin_position.lerp(target_position, i / float(amount + 0.5))
				arrow_sphere_model.show()
				add_child(arrow_sphere_model.duplicate())
		
		arrow_model.position = origin_position.lerp(target_position, amount / float(amount + 0.5))
	elif action_direction == ActionDirection.HORIZONTAL_DOT or action_direction == ActionDirection.VERTICAL_DOT:
		# bezier ftw!
		var origin_position = get_vector3_on_map(Vector3.ZERO)
		var target_position = get_vector3_on_map(-1 * position_to_target)
		var position_difference = target_position - origin_position
		var control_1 = Vector3((position_difference / 2).x, 3.0, (position_difference / 2).z)
		var control_2 = Vector3((position_difference / 2).x, 3.0, (position_difference / 2).z)
		var amount = maxi(2 * roundi(position_difference.length()), 6)
		for i in range(1, amount):
			arrow_sphere_model.position = origin_position.bezier_interpolate(control_1, control_2, target_position, i / float(amount + 0.5))
			arrow_sphere_model.show()
			add_child(arrow_sphere_model.duplicate())
		
		arrow_model.rotation_degrees.z = -75
		arrow_model.position = origin_position.bezier_interpolate(control_1, control_2, target_position, amount / float(amount + 0.5))
	
	arrow_model.show()
	arrow_model.get_child(0).show()
	add_child(arrow_model)


func clear_arrows():
	for child in get_children().filter(func(child): return child.is_in_group('ASSETS_ARROW')):
		child.queue_free()


func toggle_arrows(is_toggled):
	for child in get_children().filter(func(child): return child.is_in_group('ASSETS_ARROW')):
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
			var current_duration
			# manually slowing down the bullet in the top part of the trajectory
			if i > amount * 2/6 and i < amount * 4/6:
				current_duration = duration * 1.2
			else:
				current_duration = duration
			
			position_tween.tween_property(bullet_model, 'position', origin_position.bezier_interpolate(control_1, control_2, target_position, i / float(amount)), current_duration)
	await position_tween.finished
	
	bullet_model.queue_free()


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
