extends Civilian


func _ready():
	super()
	
	model_name = 'One civilian'
	max_health = 2
	health = 2
	damage = 0
	move_distance = 1
	action_distance = 0
	action_direction = ActionDirection.NONE
	action_type = ActionType.NONE
	can_fly = false
	
	set_health_bar()
