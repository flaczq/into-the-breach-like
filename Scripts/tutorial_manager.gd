extends Util

class_name TutorialManager

var player_1_texture: CompressedTexture2D = preload('res://Icons/player1.png')


func init_player(player: Player, level: int) -> void:
	if level == 1 or level == 2:
		player.id = 0
		player.model_name = 'Tutorial player 1'
		player.max_health = 3
		player.health = 3
		player.damage = 1
		player.move_distance = 3
		player.action_min_distance = 1
		player.action_max_distance = 9
		player.action_direction = ActionDirection.HORIZONTAL_LINE
		player.action_type = ActionType.PUSH_BACK
		player.action_damage = 0
		player.passive_type = PassiveType.NONE
		player.can_fly = false
		player.items_ids = []
		player.texture = player_1_texture
	
	player.include_upgrades()
	player.init_health_bar()


func init_enemy(enemy: Enemy, level: int) -> void:
	if level == 1:
		enemy.arrow_color = ENEMY_TUTORIAL_ARROW_COLOR
		enemy.arrow_highlighted_color = ENEMY_TUTORIAL_ARROW_HIGHLIGHTED_COLOR
		enemy.id = 0
		enemy.model_name = 'Tutorial enemy 1'
		enemy.max_health = 3
		enemy.health = 3
		enemy.damage = 1
		enemy.move_distance = 3
		enemy.action_min_distance = 1
		enemy.action_max_distance = 9
		enemy.action_direction = ActionDirection.HORIZONTAL_LINE
		enemy.action_type = ActionType.PUSH_BACK
		enemy.action_damage = 0
		enemy.passive_type = PassiveType.NONE
		enemy.can_fly = false
	elif level == 2:
		enemy.arrow_color = ENEMY_TUTORIAL_ARROW_COLOR
		enemy.arrow_highlighted_color = ENEMY_TUTORIAL_ARROW_HIGHLIGHTED_COLOR
		enemy.id = 0
		enemy.model_name = 'Tutorial enemy 1'
		enemy.max_health = 3
		enemy.health = 3
		enemy.damage = 2
		enemy.move_distance = 3
		enemy.action_min_distance = 2
		enemy.action_max_distance = 9
		enemy.action_direction = ActionDirection.HORIZONTAL_DOT
		enemy.action_type = ActionType.NONE
		enemy.action_damage = 0
		enemy.passive_type = PassiveType.NONE
		enemy.can_fly = false
	
	enemy.init_health_bar()


func init_civilian(civilian: Civilian, level: int) -> void:
	if level == 1 or level == 2:
		civilian.id = 0
		civilian.model_name = 'Tutorial civilian 1'
		civilian.max_health = 2
		civilian.health = 2
		civilian.damage = 0
		civilian.move_distance = 1
		civilian.action_min_distance = 0
		civilian.action_max_distance = 0
		civilian.action_direction = ActionDirection.NONE
		civilian.action_type = ActionType.NONE
		civilian.action_damage = 0
		civilian.passive_type = PassiveType.NONE
		civilian.can_fly = false
	
	civilian.init_health_bar()
