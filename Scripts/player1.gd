extends Player

var player_1_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_1_normal.png')
var player_1_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_1_pressed.png')
var player_1_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_1_hover.png')
var hook_normal = preload('res://Assets/aaaps/weapons_hook_normal.png')
var hook_active = preload('res://Assets/aaaps/weapons_hook_active.png')

func _ready() -> void:
	super()
	
	var player_data = get_data()
	id = player_data.id
	model_name = player_data.model_name
	max_health = player_data.max_health
	health = player_data.health
	damage = player_data.damage
	move_distance = player_data.move_distance
	action_min_distance = player_data.action_min_distance
	action_max_distance = player_data.action_max_distance
	action_direction = player_data.action_direction
	action_type = player_data.action_type
	action_damage = player_data.action_damage
	action_1_textures = [hook_normal, hook_active]
	action_2_textures = [null, null]
	passive_type = player_data.passive_type
	can_fly = player_data.can_fly
	state_types = player_data.state_types
	items_ids = player_data.items_ids
	textures = [player_1_normal_texture, player_1_pressed_texture, player_1_hover_texture]
	items_applied = player_data.items_applied


func get_data() -> Dictionary:
	return {
		'id': PlayerType.PLAYER_1,
		'model_name': 'Player 1',
		'max_health': 3,
		'health': 3,
		'damage': 1,
		'move_distance': 3,
		'action_min_distance': 2,
		'action_max_distance': 7,
		'action_direction': ActionDirection.HORIZONTAL_LINE,
		'action_type': ActionType.TOWARDS_AND_PUSH_BACK,
		'action_damage': 0,
		'action_1_textures': [hook_normal, hook_active] as Array[CompressedTexture2D],
		'action_2_textures': [null, null] as Array[CompressedTexture2D],
		'passive_type': PassiveType.NONE,
		'can_fly': true,
		'state_types': [] as Array[StateType],
		'items_ids': [ItemType.NONE, ItemType.NONE] as Array[ItemType],
		'textures': [player_1_normal_texture, player_1_pressed_texture, player_1_hover_texture] as Array[CompressedTexture2D],
		'items_applied': [false, false] as Array[bool]
	}
