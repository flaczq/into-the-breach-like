extends Player


func _ready():
	super()
	# TODO custom name
	model_name = 'Punchy boy'
	max_health = 2
	health = 2
	damage = 1
	move_distance = 4
	action_distance = 1
	action_direction = ActionDirection.VERTICAL_LINE
	action_type = ActionType.PUSH_BACK
	can_fly = false
	
	set_health_bar()
