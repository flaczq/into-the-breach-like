extends Enemy

var hook_texture: CompressedTexture2D = preload('res://Assets/aaaps/hook.png')


func _ready() -> void:
	arrow_color = ENEMY_4_ARROW_COLOR
	arrow_highlighted_color = ENEMY_ARROW_HIGHLIGHTED_COLOR
	
	super()
	
	id = EnemyType.ENEMY_4
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
	action_1_texture = hook_texture
	passive_type = PassiveType.NONE
	can_fly = false
	state_types = []
