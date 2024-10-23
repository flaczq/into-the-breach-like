extends Enemy


func _ready():
	super()
	
	model_name = 'Punch squid'
	max_health = 2
	health = 2
	damage = 1
	move_distance = 4
	action_min_distance = 1
	action_max_distance = 1
	action_direction = ActionDirection.HORIZONTAL_LINE
	action_type = ActionType.PUSH_BACK
	action_damage = 0
	can_fly = false
	
	set_health_bar()
