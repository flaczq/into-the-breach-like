extends Enemy


func _ready():
	super()
	
	model_name = 'Tanky ufo'
	max_health = 2
	health = 2
	damage = 1
	move_distance = 3
	action_min_distance = 2
	action_max_distance = 7
	action_direction = ActionDirection.HORIZONTAL_LINE
	action_type = ActionType.PULL_FRONT
	action_damage = 0
	can_fly = false
	
	set_health_bar()
