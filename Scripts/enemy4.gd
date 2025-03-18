extends Enemy


func _ready() -> void:
	arrow_color = ENEMY_4_ARROW_COLOR
	arrow_highlighted_color = ENEMY_ARROW_HIGHLIGHTED_COLOR
	
	super()
	
	id = EnemyType.ENEMY_4
	model_name = 'Enemy 4'
	max_health = 4
	health = 4
	damage = 2
	move_distance = 2
	action_min_distance = 2
	action_max_distance = 7
	action_direction = ActionDirection.HORIZONTAL_DOT
	action_type = ActionType.PULL_FRONT
	action_damage = 0
	action_1_textures = [null, null]
	passive_type = PassiveType.NONE
	can_fly = false
	state_types = []
