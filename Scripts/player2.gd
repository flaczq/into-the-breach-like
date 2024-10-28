extends Player


func _ready():
	super()
	# TODO custom name
	model_name = 'Pulling tank'
	max_health = 3
	health = 3
	damage = 1
	move_distance = 3
	action_min_distance = 1
	action_max_distance = 7
	action_direction = ActionDirection.HORIZONTAL_LINE
	action_type = ActionType.PULL_FRONT
	action_damage = 0
	can_fly = false
	
	set_health_bar()
