extends Node

class_name InitManager

const weapons_hook_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/weapons_hook_normal.png')
const weapons_hook_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/weapons_hook_pressed.png')
const weapons_hook_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/weapons_hook_hover.png')

const gem_purple_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_purple_normal.png')
const gem_purple_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_purple_pressed.png')
const gem_purple_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_purple_hover.png')
const gem_red_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_red_normal.png')
const gem_red_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_red_pressed.png')
const gem_red_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_red_hover.png')
const gem_green_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_green_normal.png')
const gem_green_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_green_pressed.png')
const gem_green_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_green_hover.png')

const player_1_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_1_normal.png')
const player_1_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_1_pressed.png')
const player_1_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_1_hover.png')
const player_2_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_2_normal.png')
const player_2_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_2_pressed.png')
const player_2_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_2_hover.png')
const player_3_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_3_normal.png')
const player_3_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_3_pressed.png')
const player_3_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_3_hover.png')

var actions_data: Array[Dictionary] = [
	{
		'id': Util.ActionType.NONE,
		'action_name': 'NONE',
		'damage': 0,
		'description': 'NONE',
		'textures': [] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.PUSH_BACK,
		'action_name': 'Pu(ni)sher',
		'damage': 0,
		'description': 'Push target back by one tile',
		'textures': [] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.TOWARDS_AND_PUSH_BACK,
		'action_name': 'Captain Hook',
		'damage': 0,
		'description': 'Move towards target and push it back by one tile',
		'textures': [weapons_hook_normal_texture, weapons_hook_pressed_texture, weapons_hook_hover_texture] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.PULL_TOGETHER,
		'action_name': 'Together forever',
		'damage': 0,
		'description': 'Pull yourself and target towards each other by one tile',
		#TODO
		'textures': [] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.CROSS_PUSH_BACK,
		'action_name': 'Blue cross',
		'damage': 0,
		'description': 'Pull yourself and target towards each other by one tile',
		#TODO
		'textures': [] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.SLOW_DOWN,
		'action_name': 'Sloooweeer',
		'damage': 0,
		'description': 'Slow target to move by one tile',
		#TODO
		'textures': [] as Array[CompressedTexture2D]
	}
]

var items_data: Array[Dictionary] = [
	{
		'id': Util.ItemType.HEALTH,
		'item_name': 'Gem 1',
		'cost': 1,
		'description': 'health + 1',
		'available': true,
		'textures': [gem_purple_normal_texture, gem_purple_pressed_texture, gem_purple_hover_texture] as Array[CompressedTexture2D],
		'applied': false
	},
	{
		'id': Util.ItemType.DAMAGE,
		'item_name': 'Gem 2',
		'cost': 1,
		'description': 'damage + 1',
		'available': true,
		'textures': [gem_red_normal_texture, gem_red_pressed_texture, gem_red_hover_texture] as Array[CompressedTexture2D],
		'applied': false
	},
	{
		'id': Util.ItemType.MOVE_DISTANCE,
		'item_name': 'Gem 3',
		'cost': 1,
		'description': 'move_distance + 1',
		'available': true,
		'textures': [gem_green_normal_texture, gem_green_pressed_texture, gem_green_hover_texture] as Array[CompressedTexture2D],
		'applied': false
	}
]

var players_data: Array[Dictionary] = [
	{
		'id': Util.PlayerType.PLAYER_TUTORIAL,
		'model_name': 'Player tutorial 1',
		'max_health': 3,
		'health': 3,
		'damage': 1,
		'move_distance': 3,
		'min_distance': ?,
		'max_distance': ?,
		'action_1_id': Util.ActionType.PUSH_BACK,
		'action_2_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'state_types': [] as Array[Util.StateType],
		'items_ids': [Util.ItemType.NONE, Util.ItemType.NONE] as Array[Util.ItemType],
		'textures': [player_1_normal_texture, player_1_pressed_texture, player_1_hover_texture] as Array[CompressedTexture2D],
		'items_applied': [false, false] as Array[bool]
	},
	{
		'id': Util.PlayerType.PLAYER_1,
		'model_name': 'Player 1',
		'max_health': 3,
		'health': 3,
		'damage': 1,
		'move_distance': 3,
		'min_distance': ?,
		'max_distance': ?,
		'action_1_id': Util.ActionType.TOWARDS_AND_PUSH_BACK,
		'action_2_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': true,
		'state_types': [] as Array[Util.StateType],
		'items_ids': [Util.ItemType.NONE, Util.ItemType.NONE] as Array[Util.ItemType],
		'textures': [player_1_normal_texture, player_1_pressed_texture, player_1_hover_texture] as Array[CompressedTexture2D],
		'items_applied': [false, false] as Array[bool]
	},
	{
		'id': Util.PlayerType.PLAYER_2,
		'model_name': 'Player 2',
		'max_health': 3,
		'health': 3,
		'damage': 1,
		'move_distance': 2,
		'min_distance': ?,
		'max_distance': ?,
		'action_1_id': Util.ActionType.PULL_TOGETHER,
		'action_2_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'state_types': [] as Array[Util.StateType],
		'items_ids': [Util.ItemType.NONE, Util.ItemType.NONE] as Array[Util.ItemType],
		'textures': [player_2_normal_texture, player_2_pressed_texture, player_2_hover_texture] as Array[CompressedTexture2D],
		'items_applied': [false, false] as Array[bool]
	},
	{
		'id': Util.PlayerType.PLAYER_3,
		'model_name': 'Player 3',
		'max_health': 3,
		'health': 3,
		'damage': 1,
		'move_distance': 2,
		'min_distance': ?,
		'max_distance': ?,
		'action_1_id': Util.ActionType.CROSS_PUSH_BACK,
		'action_2_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.HORIZONTAL_DOT,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'state_types': [] as Array[Util.StateType],
		'items_ids': [Util.ItemType.NONE, Util.ItemType.NONE] as Array[Util.ItemType],
		'textures': [player_3_normal_texture, player_3_pressed_texture, player_3_hover_texture] as Array[CompressedTexture2D],
		'items_applied': [false, false] as Array[bool]
	}
]

var enemies_data: Array[Dictionary] = [
	{
		'id': Util.EnemyType.ENEMY_TUTORIAL,
		'model_name': 'Enemy tutorial 1',
		'max_health': 3,
		'health': 3,
		'damage': 1,
		'move_distance': 3,
		'min_distance': ?,
		'max_distance': ?,
		'action_1_id': Util.ActionType.PUSH_BACK,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'state_types': [] as Array[Util.StateType],
		'textures': [] as Array[CompressedTexture2D],
		'arrow_color': Util.ENEMY_TUTORIAL_ARROW_COLOR,
		'arrow_highlighted_color': Util.ENEMY_TUTORIAL_ARROW_HIGHLIGHTED_COLOR
	},
	{
		'id': Util.EnemyType.ENEMY_1,
		'model_name': 'Enemy 1',
		'max_health': 2,
		'health': 2,
		'damage': 1,
		'move_distance': 3,
		'min_distance': ?,
		'max_distance': ?,
		'action_1_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'state_types': [] as Array[Util.StateType],
		'textures': [] as Array[CompressedTexture2D],
		'arrow_color': Util.ENEMY_1_ARROW_COLOR,
		'arrow_highlighted_color': Util.ENEMY_ARROW_HIGHLIGHTED_COLOR
	},
	{
		'id': Util.EnemyType.ENEMY_2,
		'model_name': 'Enemy 2',
		'max_health': 3,
		'health': 3,
		'damage': 1,
		'move_distance': 3,
		'min_distance': ?,
		'max_distance': ?,
		'action_1_id': Util.ActionType.SLOW_DOWN,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'state_types': [] as Array[Util.StateType],
		'textures': [] as Array[CompressedTexture2D],
		'arrow_color': Util.ENEMY_2_ARROW_COLOR,
		'arrow_highlighted_color': Util.ENEMY_ARROW_HIGHLIGHTED_COLOR
	},
	{
		'id': Util.EnemyType.ENEMY_3,
		'model_name': 'Enemy 3',
		'max_health': 3,
		'health': 3,
		'damage': 1,
		'move_distance': 2,
		'min_distance': ?,
		'max_distance': ?,
		'action_1_id': Util.ActionType.PUSH_BACK,
		'action_direction': Util.ActionDirection.HORIZONTAL_DOT,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'state_types': [] as Array[Util.StateType],
		'textures': [] as Array[CompressedTexture2D],
		'arrow_color': Util.ENEMY_3_ARROW_COLOR,
		'arrow_highlighted_color': Util.ENEMY_ARROW_HIGHLIGHTED_COLOR
	},
	{
		'id': Util.EnemyType.ENEMY_4,
		'model_name': 'Enemy 4',
		'max_health': 4,
		'health': 4,
		'damage': 2,
		'move_distance': 2,
		'min_distance': ?,
		'max_distance': ?,
		'action_1_id': Util.ActionType.PULL_FRONT,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'state_types': [] as Array[Util.StateType],
		'textures': [] as Array[CompressedTexture2D],
		'arrow_color': Util.ENEMY_4_ARROW_COLOR,
		'arrow_highlighted_color': Util.ENEMY_ARROW_HIGHLIGHTED_COLOR
	}
]

var civilians_data: Array[Dictionary] = [
	{
		'id': Util.CivilianType.CIVILIAN_TUTORIAL,
		'model_name': 'Tutorial civilian 1',
		'max_health': 2,
		'health': 2,
		'damage': 0,
		'move_distance': 1,
		'min_distance': ?,
		'max_distance': ?,
		'action_1_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.NONE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'state_types': [] as Array[Util.StateType],
		'textures': [] as Array[CompressedTexture2D]
	},
	{
		'id': Util.CivilianType.CIVILIAN_1,
		'model_name': 'One civilian',
		'max_health': 2,
		'health': 2,
		'damage': 0,
		'move_distance': 1,
		'min_distance': ?,
		'max_distance': ?,
		'action_1_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.NONE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'state_types': [] as Array[Util.StateType],
		'textures': [] as Array[CompressedTexture2D]
	}
]


#func init_all_actions() -> Array[ActionObject]:
	#var all_actions: Array[ActionObject] = []
	#for action_data in actions_data:
		#var action_object = ActionObject.new()
		#action_object.init_from_action_data(action_data)
		#all_actions.push_back(action_object)
	#return all_actions


func init_action(action_id: Util.ActionType) -> ActionObject:
	var action_object = ActionObject.new()
	var action_data = actions_data.filter(func(action): return action.id == action_id).front()
	action_object.init_from_action_data(action_data)
	return action_object


func init_all_items() -> Array[ItemObject]:
	var all_items: Array[ItemObject] = []
	for item_data in items_data:
		var item_object = ItemObject.new()
		item_object.init_from_item_data(item_data)
		all_items.push_back(item_object)
	return all_items


func init_all_players() -> Array[PlayerObject]:
	var all_players: Array[PlayerObject] = []
	for player_data in players_data:
		var player_object = PlayerObject.new()
		player_object.init_from_player_data(player_data)
		player_object.action_1 = init_action(player_object.action_1_id)
		player_object.action_2 = init_action(player_object.action_2_id)
		all_players.push_back(player_object)
	return all_players


func init_all_enemies() -> Array[EnemyObject]:
	var all_enemies: Array[EnemyObject] = []
	for enemy_data in enemies_data:
		var enemy_object = EnemyObject.new()
		enemy_object.init_from_enemy_data(enemy_data)
		enemy_object.action_1 = init_action(enemy_object.action_1_id)
		all_enemies.push_back(enemy_object)
	return all_enemies


func init_all_civilians() -> Array[CivilianObject]:
	var all_civilians: Array[CivilianObject] = []
	for civilian_data in civilians_data:
		var civilian_object = CivilianObject.new()
		civilian_object.init_from_civilian_data(civilian_data)
		civilian_object.action_1 = init_action(civilian_object.action_1_id)
		all_civilians.push_back(civilian_object)
	return all_civilians
