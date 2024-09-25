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
var assets_bullets: Array[MeshInstance3D] = []

var health: int
var damage: int
var move_distance: int
var can_fly: bool
var action_direction: ActionDirection
var action_type: ActionType
var action_distance: int
var tile: Node3D
var model_material: StandardMaterial3D
var arrow_model: MeshInstance3D
var arrow_line_model: MeshInstance3D

func _ready():
	name = name + '_' + str(randi())
	
	# to move properly among available positions
	position = Vector3.ZERO
	
	var assets = assets_scene.instantiate()
	for assets_child in assets.get_children():
		if assets_child.is_in_group('ASSETS_BULLETS'):
			assets_bullets.append_array(assets_child.get_children())
	
	arrow_model = assets_bullets.filter(func(asset_bullet): return asset_bullet.name == 'ArrowSign').front()#.duplicate()
	#arrow_model.hide()
	#add_child(arrow_model)
	
	arrow_line_model = assets_bullets.filter(func(asset_bullet): return asset_bullet.name == 'pipe-half-section').front()
	#arrow_line_model.hide()
	#add_child(arrow_line_model)


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


func spawn_bullet(target_position):
	var target_position_on_map = get_vector3_on_map(target_position - position)
	var hit_direction = Vector2i(target_position_on_map.z, target_position_on_map.x).sign()
	
	var current_arrow_model = arrow_model.duplicate()
	var current_arrow_line_model = arrow_line_model.duplicate()
	
	
	current_arrow_model.position = target_position_on_map
	current_arrow_line_model.position = target_position_on_map
	
	# hardcoded because rotations suck
	if hit_direction == Vector2i(1, 0):
		#print('DOWN (LEFT)')
		current_arrow_model.rotation_degrees.y = -90
		current_arrow_line_model.rotation_degrees.y = -180
	if hit_direction == Vector2i(-1, 0):
		#print('UP (RIGHT)')
		current_arrow_model.rotation_degrees.y = 90
		current_arrow_line_model.rotation_degrees.y = 0
	if hit_direction == Vector2i(0, 1):
		#print('RIGHT (DOWN)')
		current_arrow_model.rotation_degrees.y = 0
		current_arrow_line_model.rotation_degrees.y = -90
	if hit_direction == Vector2i(0, -1):
		#print('LEFT (UP)')
		current_arrow_model.rotation_degrees.y = 180
		current_arrow_line_model.rotation_degrees.y = 90
	
	add_child(current_arrow_model)
	add_child(current_arrow_line_model)


func clear_bullets():
	for child in get_children().filter(func(child): return child.is_in_group('ASSETS_BULLET')):
		child.queue_free()
