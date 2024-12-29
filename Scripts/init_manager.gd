extends Node

class_name InitManager

# TODO
const item_1_texture: CompressedTexture2D = preload('res://Assets/penzilla.vector-icon-pack/Icon_Award.png')
const items_data: Array[Dictionary] = [
	{ 'id': 1, 'item_name': 'Item 1', 'cost': 1, 'available': true, 'texture': item_1_texture },
	{ 'id': 2, 'item_name': 'Item 2', 'cost': 2, 'available': true, 'texture': item_1_texture },
	{ 'id': 3, 'item_name': 'Item 3', 'cost': 3, 'available': true, 'texture': item_1_texture },
	{ 'id': 4, 'item_name': 'Item 4', 'cost': 4, 'available': true, 'texture': item_1_texture }
]

var players_scripts: Array[Player] = [
	preload('res://Scripts/player1.gd').new(),
	preload('res://Scripts/player2.gd').new(),
	preload('res://Scripts/player3.gd').new()
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


# TODO
func init_available_otherthings() -> Array:
	return []
