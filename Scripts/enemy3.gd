extends Enemy


func _ready() -> void:
	arrow_color = ENEMY_3_ARROW_COLOR
	
	super()
	
	id = 3
	model_name = 'Enemy 3'
	max_health = 3
	health = 3
	damage = 1
	move_distance = 3
	action_min_distance = 1
	action_max_distance = 7
	action_direction = ActionDirection.HORIZONTAL_LINE
	action_type = ActionType.PUSH_BACK
	action_damage = 0
	passive_type = PassiveType.NONE
	can_fly = false
	state_types = []
	
	init_health_bar()
