extends Enemy


func _ready() -> void:
	arrow_color = ENEMY_2_ARROW_COLOR
	arrow_highlighted_color = ENEMY_ARROW_HIGHLIGHTED_COLOR
	
	super()
	
	id = EnemyType.ENEMY_2
	model_name = 'Enemy 2'
	max_health = 3
	health = 3
	damage = 1
	move_distance = 3
	action_min_distance = 1
	action_max_distance = 7
	action_direction = ActionDirection.HORIZONTAL_LINE
	action_type = ActionType.SLOW_DOWN
	action_damage = 0
	action_1_textures = [null, null]
	passive_type = PassiveType.NONE
	can_fly = false
	state_types = []
