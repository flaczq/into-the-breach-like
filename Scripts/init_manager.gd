extends Node

class_name InitManager

const items_data: Array[Dictionary] = [
	{ 'id': 1, 'cost': 1, 'available': true },
	{ 'id': 2, 'cost': 2, 'available': true },
	{ 'id': 3, 'cost': 3, 'available': true },
	{ 'id': 4, 'cost': 4, 'available': true }
]


func init_available_items() -> Array[ItemObject]:
	var available_items: Array[ItemObject] = []
	
	for item_data in items_data:
		var item_object = ItemObject.new()
		item_object.init_from_item_data(item_data)
		available_items.push_back(item_object)
	
	return available_items


# TODO
func init_available_otherthings() -> Array:
	return []
