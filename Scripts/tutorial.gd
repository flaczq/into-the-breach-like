extends Util


func init_player(player, level):
	if level == 1 or level == 2:
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
		player.can_fly = false
	
	player.set_health_bar()


func init_enemy(enemy, level):
	if level == 1:
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
		enemy.can_fly = false
	elif level == 2:
		enemy.model_name = 'Tutorial enemy 2'
		enemy.max_health = 3
		enemy.health = 3
		enemy.damage = 1
		enemy.move_distance = 3
		enemy.action_min_distance = 2
		enemy.action_max_distance = 9
		enemy.action_direction = ActionDirection.HORIZONTAL_DOT
		enemy.action_type = ActionType.PUSH_BACK
		enemy.action_damage = 0
		enemy.can_fly = false
	
	enemy.set_health_bar()


func init_civilian(civilian, level):
	if level == 1 or level == 2:
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
		civilian.can_fly = false
	
	civilian.set_health_bar()