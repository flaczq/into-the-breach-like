extends Player


func _ready():
	super()
	# TODO custom name
	model_name = 'Cross dot'
	max_health = 2
	health = 2
	damage = 1
	move_distance = 2
	action_distance = 7
	action_direction = ActionDirection.HORIZONTAL_DOT
	action_type = ActionType.CROSS_PUSH_BACK
	can_fly = false
	
	set_health_bar()
