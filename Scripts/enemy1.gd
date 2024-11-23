extends Enemy


func _ready() -> void:
	arrow_color = ENEMY_1_ARROW_COLOR
	
	super()
	
	id = 1
	model_name = 'Enemy 1'
	max_health = 2
	health = 2
	damage = 2
	move_distance = 3
	action_min_distance = 1
	action_max_distance = 1
	action_direction = ActionDirection.HORIZONTAL_LINE
	action_type = ActionType.MISS_MOVE
	action_damage = 0
	passive_type = PassiveType.NONE
	can_fly = false
	state_types = []
	
	init_health_bar()
