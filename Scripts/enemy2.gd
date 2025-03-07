extends Enemy

var hook_texture: CompressedTexture2D = preload('res://Assets/aaaps/hook.png')


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
	action_min_distance = 2
	action_max_distance = 7
	action_direction = ActionDirection.HORIZONTAL_DOT
	action_type = ActionType.PULL_FRONT
	action_damage = 0
	action_1_texture = hook_texture
	passive_type = PassiveType.NONE
	can_fly = false
	state_types = []
