extends Player


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
	passive_type = player_data.passive_type
	can_fly = player_data.can_fly
	state_types = player_data.state_types
	
	include_upgrades()
	init_health_bar()


func get_data() -> Dictionary:
	return {
		'id': 1,
		'model_name': 'Player 1',
		'max_health': 3,
		'health': 3,
		'damage': 1,
		'damage_upgraded': 2,
		'move_distance': 3,
		'action_min_distance': 1,
		'action_max_distance': 1,
		'action_direction': ActionDirection.HORIZONTAL_LINE,
		'action_type': ActionType.PUSH_BACK,
		'action_damage': 0,
		'passive_type': PassiveType.NONE,
		'can_fly': false,
		'state_types': [] as Array[StateType]
	}
