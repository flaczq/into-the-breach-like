extends Civilian


func _ready():
	super()
	
	model_name = 'Tutorial civilian 1'
	max_health = 2
	health = 2
	damage = 0
	move_distance = 1
	action_min_distance = 0
	action_max_distance = 0
	action_direction = ActionDirection.NONE
	action_type = ActionType.NONE
	action_damage = 0
	can_fly = false
	
	set_health_bar()
