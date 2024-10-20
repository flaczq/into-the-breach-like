extends Enemy


func _ready():
	super()
	
	model_name = 'Punch squid'
	max_health = 2
	health = 2
	damage = 1
	move_distance = 4
	action_distance = 1
	action_direction = ActionDirection.HORIZONTAL_LINE
	action_type = ActionType.NONE
	can_fly = false
	
	set_health_bar()
