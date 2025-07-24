extends Node

class_name InitManager

const weapons_hook_normal_texture: CompressedTexture2D	= preload('res://Assets/aaaps/weapons_hook_normal.png')
const weapons_hook_pressed_texture: CompressedTexture2D	= preload('res://Assets/aaaps/weapons_hook_pressed.png')
const weapons_hook_hover_texture: CompressedTexture2D	= preload('res://Assets/aaaps/weapons_hook_hover.png')

const gem_purple_normal_texture: CompressedTexture2D	= preload('res://Assets/aaaps/gem_purple_normal.png')
const gem_purple_pressed_texture: CompressedTexture2D	= preload('res://Assets/aaaps/gem_purple_pressed.png')
const gem_purple_hover_texture: CompressedTexture2D		= preload('res://Assets/aaaps/gem_purple_hover.png')
const gem_red_normal_texture: CompressedTexture2D		= preload('res://Assets/aaaps/gem_red_normal.png')
const gem_red_pressed_texture: CompressedTexture2D		= preload('res://Assets/aaaps/gem_red_pressed.png')
const gem_red_hover_texture: CompressedTexture2D		= preload('res://Assets/aaaps/gem_red_hover.png')
const gem_green_normal_texture: CompressedTexture2D		= preload('res://Assets/aaaps/gem_green_normal.png')
const gem_green_pressed_texture: CompressedTexture2D	= preload('res://Assets/aaaps/gem_green_pressed.png')
const gem_green_hover_texture: CompressedTexture2D		= preload('res://Assets/aaaps/gem_green_hover.png')

const player_1_normal_texture: CompressedTexture2D		= preload('res://Assets/aaaps/player_1_normal.png')
const player_1_pressed_texture: CompressedTexture2D		= preload('res://Assets/aaaps/player_1_pressed.png')
const player_1_hover_texture: CompressedTexture2D		= preload('res://Assets/aaaps/player_1_hover.png')
const player_2_normal_texture: CompressedTexture2D		= preload('res://Assets/aaaps/player_2_normal.png')
const player_2_pressed_texture: CompressedTexture2D		= preload('res://Assets/aaaps/player_2_pressed.png')
const player_2_hover_texture: CompressedTexture2D		= preload('res://Assets/aaaps/player_2_hover.png')
const player_3_normal_texture: CompressedTexture2D		= preload('res://Assets/aaaps/player_3_normal.png')
const player_3_pressed_texture: CompressedTexture2D		= preload('res://Assets/aaaps/player_3_pressed.png')
const player_3_hover_texture: CompressedTexture2D		= preload('res://Assets/aaaps/player_3_hover.png')

#enum ActionType {PUSH_BACK, TOWARDS_AND_PUSH_BACK, PULL_FRONT, PULL_TOGETHER, MISS_MOVE, MISS_ACTION, HIT_ALLY, GIVE_SHIELD, SLOW_DOWN, CROSS_PUSH_BACK, NONE = -1}
var actions_data: Array[Dictionary] = [
	{
		'id': Util.ActionType.NONE,
		'action_name': 'NONE',
		'damage': 0,
		#must be set, because it's just a shoot
		'min_distance': 1,
		'max_distance': 7,
		'is_upgraded': false,
		'description': 'NONE',
		'change_info': 'NONE',
		'textures': [] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.PUSH_BACK,
		'action_name': 'Pu(ni)sher',
		'damage': 0,
		'min_distance': 1,
		'max_distance': 7,
		'is_upgraded': false,
		'description': 'Push target back by one tile',
		'change_info': 'DMG: 0 -> 1',
		'textures': [] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.TOWARDS_AND_PUSH_BACK,
		'action_name': 'Captain Hook',
		'damage': 0,
		'min_distance': 2,
		'max_distance': 7,
		'is_upgraded': false,
		'description': 'Move towards target and push it back by one tile',
		'change_info': 'DMG: 0 -> 1',
		'textures': [weapons_hook_normal_texture, weapons_hook_pressed_texture, weapons_hook_hover_texture] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.PULL_FRONT,
		'action_name': 'Together forever',
		'damage': 0,
		'min_distance': 2,
		'max_distance': 7,
		'is_upgraded': false,
		'description': 'Pull target towards by one tile',
		'change_info': 'DMG: 0 -> 1',
		#TODO
		'textures': [] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.PULL_TOGETHER,
		'action_name': 'Together forever',
		'damage': 0,
		'min_distance': 3,
		'max_distance': 7,
		'is_upgraded': false,
		'description': 'Pull yourself and target towards each other by one tile',
		'change_info': 'DMG: 0 -> 1',
		#TODO
		'textures': [] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.MISS_MOVE,
		'action_name': 'Don\'t miss me',
		'damage': 0,
		'min_distance': 1,
		'max_distance': 1,
		'is_upgraded': false,
		'description': 'Target can\'t make actions next turn',
		'change_info': 'DISTANCE: 1 -> 2',
		#TODO
		'textures': [] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.SLOW_DOWN,
		'action_name': 'Sloooweeer',
		'damage': 0,
		'min_distance': 1,
		'max_distance': 1,
		'is_upgraded': false,
		'description': 'Slow target to move by one tile',
		'change_info': 'DISTANCE: 1 -> 2',
		#TODO
		'textures': [] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ActionType.CROSS_PUSH_BACK,
		'action_name': 'Blue cross',
		'damage': 0,
		'min_distance': 2,
		'max_distance': 7,
		'is_upgraded': false,
		'description': 'Push tiles in cross by one tile',
		'change_info': 'DMG: 0 -> 1',
		#TODO
		'textures': [] as Array[CompressedTexture2D]
	}
]

var items_data: Array[Dictionary] = [
	{
		'id': Util.ItemType.NONE,
		'item_name': 'NONE',
		'cost': 0,
		'description': 'NONE',
		'is_available': false,
		'is_applied': false,
		'textures': [] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ItemType.HEALTH,
		'item_name': 'Gem 1',
		'cost': 1,
		'description': 'health + 1',
		'is_available': true,
		'is_applied': false,
		'textures': [gem_purple_normal_texture, gem_purple_pressed_texture, gem_purple_hover_texture] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ItemType.DAMAGE,
		'item_name': 'Gem 2',
		'cost': 1,
		'description': 'damage + 1',
		'is_available': true,
		'is_applied': false,
		'textures': [gem_red_normal_texture, gem_red_pressed_texture, gem_red_hover_texture] as Array[CompressedTexture2D]
	},
	{
		'id': Util.ItemType.MOVE_DISTANCE,
		'item_name': 'Gem 3',
		'cost': 1,
		'description': 'move_distance + 1',
		'is_available': true,
		'is_applied': false,
		'textures': [gem_green_normal_texture, gem_green_pressed_texture, gem_green_hover_texture] as Array[CompressedTexture2D]
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
		'action_1_id': Util.ActionType.PUSH_BACK,
		'action_2_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'can_swim': true,
		'state_types': [] as Array[Util.StateType],
		#'items_ids': [Util.ItemType.NONE, Util.ItemType.NONE] as Array[Util.ItemType],
		'textures': [player_1_normal_texture, player_1_pressed_texture, player_1_hover_texture] as Array[CompressedTexture2D],
		#'items_applied': [false, false] as Array[bool]
		'item_1_id': Util.ItemType.NONE,
		'item_2_id': Util.ItemType.NONE
	},
	{
		'id': Util.PlayerType.PLAYER_1,
		'model_name': 'Player 1',
		'max_health': 3,
		'health': 3,
		'damage': 1,
		'move_distance': 3,
		'action_1_id': Util.ActionType.TOWARDS_AND_PUSH_BACK,
		'action_2_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': true,
		'can_swim': true,
		'state_types': [] as Array[Util.StateType],
		'textures': [player_1_normal_texture, player_1_pressed_texture, player_1_hover_texture] as Array[CompressedTexture2D],
		'item_1_id': Util.ItemType.NONE,
		'item_2_id': Util.ItemType.NONE
	},
	{
		'id': Util.PlayerType.PLAYER_2,
		'model_name': 'Player 2',
		'max_health': 3,
		'health': 3,
		'damage': 1,
		'move_distance': 2,
		'action_1_id': Util.ActionType.PULL_TOGETHER,
		'action_2_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'can_swim': true,
		'state_types': [] as Array[Util.StateType],
		'textures': [player_2_normal_texture, player_2_pressed_texture, player_2_hover_texture] as Array[CompressedTexture2D],
		'item_1_id': Util.ItemType.NONE,
		'item_2_id': Util.ItemType.NONE
	},
	{
		'id': Util.PlayerType.PLAYER_3,
		'model_name': 'Player 3',
		'max_health': 3,
		'health': 3,
		'damage': 1,
		'move_distance': 2,
		'action_1_id': Util.ActionType.CROSS_PUSH_BACK,
		'action_2_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.HORIZONTAL_DOT,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'can_swim': true,
		'state_types': [] as Array[Util.StateType],
		'textures': [player_3_normal_texture, player_3_pressed_texture, player_3_hover_texture] as Array[CompressedTexture2D],
		'item_1_id': Util.ItemType.NONE,
		'item_2_id': Util.ItemType.NONE
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
		'action_1_id': Util.ActionType.PUSH_BACK,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'can_swim': false,
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
		'action_1_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'can_swim': false,
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
		'action_1_id': Util.ActionType.SLOW_DOWN,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'can_swim': false,
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
		'action_1_id': Util.ActionType.PUSH_BACK,
		'action_direction': Util.ActionDirection.HORIZONTAL_DOT,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'can_swim': false,
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
		'action_1_id': Util.ActionType.PULL_FRONT,
		'action_direction': Util.ActionDirection.HORIZONTAL_LINE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'can_swim': false,
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
		'action_1_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.NONE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'can_swim': false,
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
		'action_1_id': Util.ActionType.NONE,
		'action_direction': Util.ActionDirection.NONE,
		'passive_type': Util.PassiveType.NONE,
		'can_fly': false,
		'can_swim': false,
		'state_types': [] as Array[Util.StateType],
		'textures': [] as Array[CompressedTexture2D]
	}
]


func init_tutorial_player() -> Player:
	var tutorial_player_data = players_data.filter(func(player_data): return player_data.id == Util.PlayerType.PLAYER_TUTORIAL).front()
	var tutorial_player = Player.new()
	tutorial_player.id = tutorial_player_data.id
	tutorial_player.model_name = tutorial_player_data.model_name
	tutorial_player.max_health = tutorial_player_data.max_health
	tutorial_player.health = tutorial_player_data.health
	tutorial_player.damage = tutorial_player_data.damage
	tutorial_player.move_distance = tutorial_player_data.move_distance
	tutorial_player.action_1 = init_action(tutorial_player_data.action_1_id)
	tutorial_player.action_2 = init_action(tutorial_player_data.action_2_id)
	tutorial_player.action_direction = tutorial_player_data.action_direction
	tutorial_player.passive_type = tutorial_player_data.passive_type
	tutorial_player.can_fly = tutorial_player_data.can_fly
	tutorial_player.can_swim = tutorial_player_data.can_swim
	tutorial_player.state_types = tutorial_player_data.state_types.duplicate()
	tutorial_player.textures = tutorial_player_data.textures.duplicate()
	tutorial_player.item_1 = init_item(tutorial_player_data.item_1_id)
	tutorial_player.item_2 = init_item(tutorial_player_data.item_2_id)
	return tutorial_player


func init_playable_players() -> Array[Player]:
	var playable_players = [] as Array[Player]
	for player_data in players_data.filter(func(player_data): return player_data.id != Util.PlayerType.PLAYER_TUTORIAL):
		var playable_player = Player.new()
		playable_player.id = player_data.id
		playable_player.model_name = player_data.model_name
		playable_player.max_health = player_data.max_health
		playable_player.health = player_data.health
		playable_player.damage = player_data.damage
		playable_player.move_distance = player_data.move_distance
		playable_player.action_1 = init_action(player_data.action_1_id)
		playable_player.action_2 = init_action(player_data.action_2_id)
		playable_player.action_direction = player_data.action_direction
		playable_player.passive_type = player_data.passive_type
		playable_player.can_fly = player_data.can_fly
		playable_player.can_swim = player_data.can_swim
		playable_player.state_types = player_data.state_types.duplicate()
		playable_player.textures = player_data.textures.duplicate()
		playable_player.item_1 = init_item(player_data.item_1_id)
		playable_player.item_2 = init_item(player_data.item_2_id)
		playable_players.push_back(playable_player)
	return playable_players


func init_player(target_player: Player, id: Util.PlayerType) -> void:
	var player_data = Util.get_selected_player(id)
	target_player.id = player_data.id
	target_player.model_name = player_data.model_name
	target_player.max_health = player_data.max_health
	target_player.health = player_data.health
	target_player.damage = player_data.damage
	target_player.move_distance = player_data.move_distance
	target_player.action_1 = player_data.action_1
	target_player.action_2 = player_data.action_2
	target_player.action_direction = player_data.action_direction
	target_player.passive_type = player_data.passive_type
	target_player.can_fly = player_data.can_fly
	target_player.can_swim = player_data.can_swim
	target_player.state_types = player_data.state_types.duplicate()
	target_player.textures = player_data.textures.duplicate()
	target_player.item_1 = player_data.item_1
	target_player.item_2 = player_data.item_2


func init_enemy(target_enemy: Enemy, id: Util.EnemyType) -> void:
	var enemy_data = enemies_data.filter(func(enemy_data): return enemy_data.id == id).front()
	target_enemy.id = enemy_data.id
	target_enemy.model_name = enemy_data.model_name
	target_enemy.max_health = enemy_data.max_health
	target_enemy.health = enemy_data.health
	target_enemy.damage = enemy_data.damage
	target_enemy.move_distance = enemy_data.move_distance
	target_enemy.action_1 = init_action(enemy_data.action_1_id)
	target_enemy.action_direction = enemy_data.action_direction
	target_enemy.passive_type = enemy_data.passive_type
	target_enemy.can_fly = enemy_data.can_fly
	target_enemy.can_swim = enemy_data.can_swim
	target_enemy.state_types = enemy_data.state_types.duplicate()
	target_enemy.textures = enemy_data.textures.duplicate()
	target_enemy.arrow_color = enemy_data.arrow_color
	target_enemy.arrow_highlighted_color = enemy_data.arrow_highlighted_color


func init_civilian(target_civilian: Civilian, id: Util.CivilianType) -> void:
	var civilian_data = civilians_data.filter(func(civilian_data): return civilian_data.id == id).front()
	target_civilian.id = civilian_data.id
	target_civilian.model_name = civilian_data.model_name
	target_civilian.max_health = civilian_data.max_health
	target_civilian.health = civilian_data.health
	target_civilian.damage = civilian_data.damage
	target_civilian.move_distance = civilian_data.move_distance
	target_civilian.action_1 = init_action(civilian_data.action_1_id)
	target_civilian.action_direction = civilian_data.action_direction
	target_civilian.passive_type = civilian_data.passive_type
	target_civilian.can_fly = civilian_data.can_fly
	target_civilian.can_swim = civilian_data.can_swim
	target_civilian.state_types = civilian_data.state_types.duplicate()
	target_civilian.textures = civilian_data.textures.duplicate()


func init_action(action_id: Util.ActionType) -> ActionObject:
	var action_object = ActionObject.new()
	var action_data = actions_data.filter(func(action_data): return action_data.id == action_id).front()
	action_object.init_from_action_data(action_data)
	return action_object


func init_available_items() -> Array[ItemObject]:
	var available_items = [] as Array[ItemObject]
	for item_data in items_data.filter(func(item_data): return item_data.is_available and Global.selected_items.all(func(selected_item): return selected_item.id != item_data.id)):
		var item_object = ItemObject.new()
		item_object.init_from_item_data(item_data)
		available_items.push_back(item_object)
	return available_items


func init_item(item_id: Util.ItemType) -> ItemObject:
	var item_object = ItemObject.new()
	var item_data = items_data.filter(func(item_data): return item_data.id == item_id).front()
	item_object.init_from_item_data(item_data)
	return item_object
