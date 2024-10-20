extends Enemy


func _ready():
	super()
	
	model_name = 'Tanky ufo'
	max_health = 2
	health = 2
	damage = 1
	move_distance = 3
	action_distance = 7
	action_direction = ActionDirection.HORIZONTAL_LINE
	action_type = ActionType.NONE
	can_fly = false
	
	set_health_bar()
