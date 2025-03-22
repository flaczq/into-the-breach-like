extends Node

class_name InitManager

const player_1_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_1_normal.png')
const player_1_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_1_pressed.png')
const player_1_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_1_hover.png')
const player_2_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_2_normal.png')
const player_2_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_2_pressed.png')
const player_2_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_2_hover.png')
const player_3_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_3_normal.png')
const player_3_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_3_pressed.png')
const player_3_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_3_hover.png')

const gem_purple_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_purple_normal.png')
const gem_purple_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_purple_pressed.png')
const gem_purple_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_purple_hover.png')
const gem_red_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_red_normal.png')
const gem_red_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_red_pressed.png')
const gem_red_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_red_hover.png')
const gem_green_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_green_normal.png')
const gem_green_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_green_pressed.png')
const gem_green_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/gem_green_hover.png')

const weapons_hook_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/weapons_hook_normal.png')
const weapons_hook_pressed_texture: CompressedTexture2D = preload('res://Assets/aaaps/weapons_hook_pressed.png')
const weapons_hook_hover_texture: CompressedTexture2D = preload('res://Assets/aaaps/weapons_hook_hover.png')

var players_data: Array[Dictionary] = [
	{
		'id': Util.PlayerType.PLAYER_1,
		'model_name': 'Player 1',
		'max_health': 3,
		'health': 3,
		'damage': 1,
		'move_distance': 3,
		'action': Util.get_action(Util.ActionType.TOWARDS_AND_PUSH_BACK),
		#'action_min_distance': 2,
		#'action_max_distance': 7,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		#'action_type': Util.ActionType.TOWARDS_AND_PUSH_BACK,
		#'action_damage': 0,
		#'action_1_textures': [hook_normal, hook_active] as Array[CompressedTexture2D],
		#'action_2_textures': [null, null] as Array[CompressedTexture2D],
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
		'action': Util.get_action(Util.ActionType.PULL_TOGETHER),
		#'action_min_distance': 3,
		#'action_max_distance': 7,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		#'action_type': Util.ActionType.PULL_TOGETHER,
		#'action_damage': 0,
		#'action_1_textures': [hook_normal, hook_active] as Array[CompressedTexture2D],
		#'action_2_textures': [null, null] as Array[CompressedTexture2D],
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
		'action': Util.get_action(Util.ActionType.CROSS_PUSH_BACK),
		#'action_min_distance': 2,
		#'action_max_distance': 7,
		'action_direction': Util.ActionDirection.HORIZONTAL_DOT,
		#'action_type': Util.ActionType.CROSS_PUSH_BACK,
		#'action_damage': 0,
		#'action_1_textures': [hook_normal, hook_active] as Array[CompressedTexture2D],
		#'action_2_textures': [null, null] as Array[CompressedTexture2D],
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'state_types': [] as Array[Util.StateType],
		'items_ids': [Util.ItemType.NONE, Util.ItemType.NONE] as Array[Util.ItemType],
		'textures': [player_3_normal_texture, player_3_pressed_texture, player_3_hover_texture] as Array[CompressedTexture2D],
		'items_applied': [false, false] as Array[bool]
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

var actions_data: Array[Dictionary] = [
	{
		'id': Util.ActionType.TOWARDS_AND_PUSH_BACK,
		'action_name': 'Captain Hook',
		'damage': 0,
		'min_distance': 2,
		'max_distance': 7,
		'description': 'Move towards target and push it back by one tile',
		'textures': [weapons_hook_normal_texture, weapons_hook_pressed_texture, weapons_hook_hover_texture] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.PULL_TOGETHER,
		'action_name': 'Together forever',
		'damage': 0,
		'min_distance': 3,
		'max_distance': 7,
		'description': 'Pull yourself and target towards each other by one tile',
		#TODO
		'textures': [] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.CROSS_PUSH_BACK,
		'action_name': 'Blue cross',
		'damage': 0,
		'min_distance': 2,
		'max_distance': 7,
		'description': 'Pull yourself and target towards each other by one tile',
		#TODO
		'textures': [] as Array[CompressedTexture2D]
	}
]


func init_all_players() -> Array[PlayerObject]:
	var all_players: Array[PlayerObject] = []
	for player_data in players_data:
		var player_object = PlayerObject.new()
		player_object.init_from_player_data(player_data)
		all_players.push_back(player_object)
	return all_players


func init_all_items() -> Array[ItemObject]:
	var all_items: Array[ItemObject] = []
	for item_data in items_data:
		var item_object = ItemObject.new()
		item_object.init_from_item_data(item_data)
		all_items.push_back(item_object)
	return all_items


func init_all_actions() -> Array[ActionObject]:
	var all_actions: Array[ActionObject] = []
	for action_data in actions_data:
		var action_object = ActionObject.new()
		action_object.init_from_action_data(action_data)
		all_actions.push_back(action_object)
	return all_actions
