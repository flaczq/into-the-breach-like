extends Enemy


func _ready():
	super()
	
	model_name = 'VerticAlien'
	max_health = 2
	health = 2
	damage = 1
	move_distance = 2
	action_distance = 7
	action_direction = ActionDirection.VERTICAL_DOT
	action_type = ActionType.PUSH_BACK
	can_fly = false
	
	set_health_bar()
