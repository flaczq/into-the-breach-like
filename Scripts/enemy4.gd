extends Enemy


func _ready():
	arrow_color = ENEMY_4_ARROW_COLOR
	
	super()
	
	model_name = 'Enemy 4'
	max_health = 4
	health = 4
	damage = 2
	move_distance = 3
	action_min_distance = 1
	action_max_distance = 7
	action_direction = ActionDirection.HORIZONTAL_LINE
	action_type = ActionType.NONE
	action_damage = 0
	can_fly = false
	
	set_health_bar()
