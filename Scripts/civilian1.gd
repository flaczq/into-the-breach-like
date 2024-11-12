extends Civilian


func _ready() -> void:
	super()
	
	model_name = 'One civilian'
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
	
	init_health_bar()
