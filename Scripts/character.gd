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

var default_arrow_model: Node3D
var default_arrow_line_model: MeshInstance3D
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
	
	var assets = assets_scene.instantiate()
	for assets_group in assets.get_children():
		if assets_group.is_in_group('ASSETS_BULLETS'):
			for assets_child in assets_group.get_children():
				if assets_child.name == 'ArrowSignContainer':
					default_arrow_model = assets_child
				elif assets_child.name == 'doormat':
					default_arrow_line_model = assets_child
				elif assets_child.name == 'weapon-sword':
					default_bullet_model = assets_child


func init(character_init_data):
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


func spawn_arrow(target):
	var target_position_on_map = get_vector3_on_map(position - target.position)
	var hit_distance = Vector2i(target_position_on_map.z, target_position_on_map.x)
	var hit_direction = hit_distance.sign()
	var direction = get_direction(hit_direction)
	
	var arrow_model = default_arrow_model.duplicate()
	var arrow_line_model = default_arrow_line_model.duplicate()
	
	arrow_model.position = get_vector3_on_map(Vector3.ZERO)
	arrow_line_model.position = get_vector3_on_map(Vector3.ZERO)
		
	# hardcoded because rotations suck
	if direction == HitDirection.DOWN_LEFT:
		arrow_model.rotation_degrees.y = -90
		arrow_line_model.rotation_degrees.y = -90
	elif direction == HitDirection.UP_RIGHT:
		arrow_model.rotation_degrees.y = 90
		arrow_line_model.rotation_degrees.y = 90
	elif direction == HitDirection.RIGHT_DOWN:
		arrow_model.rotation_degrees.y = 0
		arrow_line_model.rotation_degrees.y = 0
	elif direction == HitDirection.LEFT_UP:
		arrow_model.rotation_degrees.y = 180
		arrow_line_model.rotation_degrees.y = 180
	elif direction == HitDirection.DOWN:
		arrow_model.rotation_degrees.y = -45
		arrow_line_model.rotation_degrees.y = -45
	elif direction == HitDirection.UP:
		arrow_model.rotation_degrees.y = 135
		arrow_line_model.rotation_degrees.y = 135
	elif direction == HitDirection.RIGHT:
		arrow_model.rotation_degrees.y = 45
		arrow_line_model.rotation_degrees.y = 45
	elif direction == HitDirection.LEFT:
		arrow_model.rotation_degrees.y = -135
		arrow_line_model.rotation_degrees.y = -135
	
	var position_offset = Vector3(hit_direction.y, 0, hit_direction.x)
	if action_direction == ActionDirection.HORIZONTAL_LINE or action_direction == ActionDirection.VERTICAL_LINE:
		arrow_model.position = get_vector3_on_map(position_offset * 0.3 - target_position_on_map)
	
		var default_distance
		if action_direction == ActionDirection.HORIZONTAL_LINE:
			default_distance = 0.6
		elif action_direction == ActionDirection.VERTICAL_LINE:
			default_distance = 0.5
		
		var distance = default_distance
		while absi(hit_distance.y) > distance + default_distance or absi(hit_distance.x) > distance + default_distance:
			arrow_line_model.position = arrow_model.position + position_offset * distance
			arrow_line_model.show()
			add_child(arrow_line_model.duplicate())
			
			distance += default_distance
	elif action_direction == ActionDirection.HORIZONTAL_DOT or action_direction == ActionDirection.VERTICAL_DOT:
		var arrow_model_position = position_offset * 0.3 - target_position_on_map
		arrow_model.rotation_degrees.z = -60
		arrow_model.position = Vector3(arrow_model_position.x, 1.0, arrow_model_position.z)
	
	arrow_model.show()
	add_child(arrow_model)


func clear_arrows():
	for child in get_children().filter(func(child): return child.is_in_group('ASSETS_ARROW')):
		child.queue_free()


func spawn_bullet(target):
	var target_position_on_map = get_vector3_on_map(position - target.position)
	var hit_distance = Vector2i(target_position_on_map.z, target_position_on_map.x)
	var hit_direction = hit_distance.sign()
	var direction = get_direction(hit_direction)
	
	var bullet_model = default_bullet_model.duplicate()
	
	bullet_model.position = get_vector3_on_map(Vector3.ZERO)
	
	# hardcoded because rotations suck
	if direction == HitDirection.DOWN_LEFT:
		bullet_model.rotation_degrees.y = 90
	elif direction == HitDirection.UP_RIGHT:
		bullet_model.rotation_degrees.y = 90
	elif direction == HitDirection.RIGHT_DOWN:
		bullet_model.rotation_degrees.y = 90
	elif direction == HitDirection.LEFT_UP:
		bullet_model.rotation_degrees.y = 90
	elif direction == HitDirection.DOWN:
		bullet_model.rotation_degrees.y = -45
	elif direction == HitDirection.UP:
		bullet_model.rotation_degrees.y = 135
	elif direction == HitDirection.RIGHT:
		bullet_model.rotation_degrees.y = 45
	elif direction == HitDirection.LEFT:
		bullet_model.rotation_degrees.y = -135
	
	bullet_model.show()
	add_child(bullet_model)
	
	# constant speed of 8 tiles per second
	var duration = target_position_on_map.length() / 8.0
	var position_tween = create_tween()
	if action_direction == ActionDirection.HORIZONTAL_LINE or action_direction == ActionDirection.VERTICAL_LINE:
		position_tween.tween_property(bullet_model, 'position', get_vector3_on_map(-1 * target_position_on_map), duration)
	else:
		position_tween.tween_property(bullet_model, 'position', Vector3(-1 * target_position_on_map.x / 2, 1.0, -1 * target_position_on_map.z / 2), duration / 2)
		position_tween.tween_property(bullet_model, 'position', get_vector3_on_map(-1 * target_position_on_map), duration / 2)
	await position_tween.finished
	
	bullet_model.queue_free()
