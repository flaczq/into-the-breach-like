extends Player


func _ready():
	super()
	# TODO custom name
	model_name = 'Cross dot'
	max_health = 2
	health = 2
	damage = 1
	move_distance = 2
	action_min_distance = 3
	action_max_distance = 7
	action_direction = ActionDirection.HORIZONTAL_DOT
	action_type = ActionType.CROSS_PUSH_BACK
	action_damage = 0
	can_fly = false
	
	set_health_bar()
