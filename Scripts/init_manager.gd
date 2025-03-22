extends Node

class_name InitManager

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

var players_scripts: Array[Player] = [
	preload('res://Scripts/player1.gd').new(),
	preload('res://Scripts/player2.gd').new(),
	preload('res://Scripts/player3.gd').new()
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
	}
]


func init_all_players() -> Array[PlayerObject]:
	var all_players: Array[PlayerObject] = []
	for player_script in players_scripts:
		var player_object = PlayerObject.new()
		var player_data = player_script.get_data()
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
