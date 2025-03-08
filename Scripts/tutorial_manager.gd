extends Util

class_name TutorialManager

var player_1_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_1_normal.png')
var player_1_active_texture: CompressedTexture2D = preload('res://Assets/aaaps/player_1_active.png')
var hook_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/hook_normal.png')
var hook_active_texture: CompressedTexture2D = preload('res://Assets/aaaps/hook_active.png')
var plus_normal_texture: CompressedTexture2D = preload('res://Assets/aaaps/plus_normal.png')
var plus_active_texture: CompressedTexture2D = preload('res://Assets/aaaps/plus_active.png')


func init_player(player: Player, level: int) -> void:
	if level == 1 or level == 2:
		player.id = PlayerType.PLAYER_TUTORIAL
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
		player.action_1_textures = [hook_normal_texture, hook_active_texture]
		player.action_2_textures = [plus_normal_texture, plus_active_texture]
		player.passive_type = PassiveType.NONE
		player.can_fly = false
		player.items_ids = [ItemType.NONE, ItemType.NONE] as Array[ItemType]
		player.textures = [player_1_normal_texture, player_1_active_texture]
		player.items_applied = [false, false] as Array[bool]


func init_enemy(enemy: Enemy, level: int) -> void:
	if level == 1:
		enemy.arrow_color = ENEMY_TUTORIAL_ARROW_COLOR
		enemy.arrow_highlighted_color = ENEMY_TUTORIAL_ARROW_HIGHLIGHTED_COLOR
		enemy.id = EnemyType.ENEMY_TUTORIAL
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
		enemy.action_1_textures = [hook_normal_texture, hook_active_texture]
		enemy.passive_type = PassiveType.NONE
		enemy.can_fly = false
	elif level == 2:
		enemy.arrow_color = ENEMY_TUTORIAL_ARROW_COLOR
		enemy.arrow_highlighted_color = ENEMY_TUTORIAL_ARROW_HIGHLIGHTED_COLOR
		enemy.id = EnemyType.ENEMY_TUTORIAL
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
		enemy.action_1_textures = [hook_normal_texture, hook_active_texture]
		enemy.passive_type = PassiveType.NONE
		enemy.can_fly = false


func init_civilian(civilian: Civilian, level: int) -> void:
	if level == 1 or level == 2:
		civilian.id = CivilianType.CIVILIAN_TUTORIAL
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
		civilian.action_1_texture = null
		civilian.passive_type = PassiveType.NONE
		civilian.can_fly = false
