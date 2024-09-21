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
var bullet_model: MeshInstance3D
var bullet_line_model: MeshInstance3D

func _ready():
	name = name + '_' + str(randi())
	
	# to move properly among available positions
	position = Vector3.ZERO
	
	var assets = assets_scene.instantiate()
	for assets_child in assets.get_children():
		if assets_child.is_in_group('ASSETS_BULLETS'):
			assets_bullets.append_array(assets_child.get_children())
	
	bullet_model = assets_bullets.front().duplicate()
	bullet_model.hide()
	add_child(bullet_model)
	
	bullet_line_model = MeshInstance3D.new()
	bullet_line_model.hide()
	add_child(bullet_line_model)


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
	# spawn bullet line
	var target_local_position = target_position - position
	var bullet_line_immediate_mesh = ImmediateMesh.new()
	var bullet_line_material = StandardMaterial3D.new()
	
	bullet_line_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, bullet_line_material)
	bullet_line_immediate_mesh.surface_add_vertex(Vector3.ZERO)
	bullet_line_immediate_mesh.surface_add_vertex(target_local_position)
	bullet_line_immediate_mesh.surface_end()
	
	# line vertices can be at y-axis = 0
	bullet_line_model.position = Vector3(0, 0.5, 0)
	bullet_line_model.mesh = bullet_line_immediate_mesh
	bullet_line_model.show()
	
	# spawn bullet at position = 0 to calculate rotation
	bullet_model.position = Vector3(0, 0.5, 0)
	bullet_model.look_at(Vector3(target_position.x, 0.5, target_position.z))
	# fix rotation for y-axis only
	bullet_model.set_rotation_degrees(bullet_model.rotation_degrees * Vector3.UP + Vector3(0, 90, 0))
	bullet_model.position = Vector3(target_local_position.x, 0.5, target_local_position.z)
	bullet_model.show()
