extends Enemy


func _ready():
	super()
	
	model_name = 'Enemy 1'
	max_health = 3
	health = 3
	damage = 1
	move_distance = 3
	action_min_distance = 1
	action_max_distance = 1
	action_direction = ActionDirection.HORIZONTAL_LINE
	action_type = ActionType.PUSH_BACK
	action_damage = 0
	can_fly = false
	
	set_health_bar()
