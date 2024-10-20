extends Player


func _ready():
	super()
	# TODO custom name
	model_name = 'Pulling tank'
	max_health = 2
	health = 2
	damage = 1
	move_distance = 3
	action_distance = 7
	action_direction = ActionDirection.HORIZONTAL_LINE
	action_type = ActionType.PULL_FRONT
	can_fly = false
	
	set_health_bar()
