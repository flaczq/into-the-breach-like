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
var tile: Node3D
var model_material: StandardMaterial3D
var bullet_model: MeshInstance3D

func _ready():
	# to move properly among available positions
	position = Vector3.ZERO
	
	var assets = assets_scene.instantiate()
	for assets_child in assets.get_children():
		if assets_child.is_in_group('ASSETS_BULLETS'):
			assets_bullets.append_array(assets_child.get_children())
	
	bullet_model = assets_bullets.front().duplicate()
	bullet_model.hide()
	add_child(bullet_model)


func init(character_init_data):
	health = character_init_data.health
	damage = character_init_data.damage
	move_distance = character_init_data.move_distance
	can_fly = character_init_data.can_fly
	action_direction = character_init_data.action_direction
	action_type = character_init_data.action_type


func apply_action_type(action_type, origin_tile_coords):
	match action_type:
		ActionType.PUSH_BACK: action_push_back.emit(self, origin_tile_coords)
		ActionType.PULL_FRONT: action_pull_front.emit(self, origin_tile_coords)
		ActionType.MISS_ACTION: action_miss_action.emit(self)
		ActionType.HIT_ALLY: action_hit_ally.emit(self)
		ActionType.GIVE_SHIELD: action_give_shield.emit(self)
		ActionType.SLOW_DOWN: action_slow_down.emit(self)
		_: print('no action')
