extends Enemy


func _ready():
	super()
	
	model_name = 'VerticAlien'
	max_health = 3
	health = 3
	damage = 2
	move_distance = 2
	action_min_distance = 3
	action_max_distance = 7
	action_direction = ActionDirection.VERTICAL_DOT
	action_type = ActionType.NONE
	action_damage = 0
	can_fly = false
	
	set_health_bar()
