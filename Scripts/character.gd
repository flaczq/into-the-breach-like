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

var assets: Node
var default_arrow_model: MeshInstance3D
var default_arrow_line_model: MeshInstance3D
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
	
	assets = assets_scene.instantiate()


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
	
	if action_direction == ActionDirection.HORIZONTAL_LINE or action_direction == ActionDirection.VERTICAL_LINE:
		var distance = 0.5
		while abs(hit_distance.y) > distance + 0.5 or abs(hit_distance.x) > distance + 0.5:
			arrow_line_model.position = get_vector3_on_map(position_offset * distance)
			add_child(arrow_line_model.duplicate())
			distance += 0.5


func clear_arrows():
	for child in get_children().filter(func(child): return child.is_in_group('ASSETS_ARROW')):
		child.queue_free()
