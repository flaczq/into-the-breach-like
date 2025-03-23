extends Node3D

class_name Util

enum Language {EN, PL}
enum CameraPosition {HIGH, MIDDLE, LOW}
enum BuildMode {RELEASE, DEBUG}
enum EngineMode {MENU, GAME, EDITOR, AWAITING}
enum PlayerType {PLAYER_TUTORIAL, PLAYER_1, PLAYER_2, PLAYER_3, NONE = -1}
enum EnemyType {ENEMY_TUTORIAL, ENEMY_1, ENEMY_2, ENEMY_3, ENEMY_4, NONE = -1}
enum CivilianType {CIVILIAN_TUTORIAL, CIVILIAN_1}
enum ItemType {HEALTH, DAMAGE, SHIELD, MOVE_DISTANCE, FLYING, NONE = -1}
enum ActionDirection {HORIZONTAL_LINE, VERTICAL_LINE, HORIZONTAL_DOT, VERTICAL_DOT, NONE = -1}
enum ActionType {PUSH_BACK, TOWARDS_AND_PUSH_BACK, PULL_FRONT, PULL_TOGETHER, MISS_MOVE, MISS_ACTION, HIT_ALLY, GIVE_SHIELD, SLOW_DOWN, CROSS_PUSH_BACK, NONE = -1}
enum PassiveType {HEALING, NONE = -1}
enum StateType {MISSED_MOVE, MISSED_ACTION, MADE_HIT_ALLY, GAVE_SHIELD, SLOWED_DOWN, NONE = -1}
enum PhaseType {MOVE, ACTION, WAIT}
enum TileType {PLAIN, GRASS, TREE, MOUNTAIN, VOLCANO, WATER, LAVA, FLOOR, HOLE}
enum TileHealthType {HEALTHY, DAMAGED, DESTROYED, DESTRUCTIBLE_HEALTHY, DESTRUCTIBLE_DAMAGED, INDESTRUCTIBLE, INDESTRUCTIBLE_WALKABLE}
enum HitDirection {DOWN_LEFT, UP_RIGHT, RIGHT_DOWN, LEFT_UP, DOWN, UP, RIGHT, LEFT, UNKNOWN = -1}
enum LevelType {TUTORIAL, KILL_ENEMIES, SURVIVE_TURNS, SAVE_CIVILIANS, SAVE_TILES, NONE = -1}
enum LevelEvent {ENEMIES_FROM_BELOW, ENEMIES_FROM_ABOVE, FALLING_MISSLE, FALLING_ROCK, MINE, FLOOD, MOVING_PLATFORMS, NONE = -1}
enum LevelObjective {ALL_ENEMIES_DEAD, LESS_THAN_HALF_TILES_DAMAGED, NO_PLAYERS_DEAD}

const TILE_HIGHLIGHTED_COLOR = Color('91c3ff')
const PLAYER_ARROW_COLOR: Color = Color('005fcd')
const ENEMY_TUTORIAL_ARROW_COLOR: Color = Color('cb003c')
const ENEMY_TUTORIAL_ARROW_HIGHLIGHTED_COLOR: Color = Color('ffa3ac')
const ENEMY_1_ARROW_COLOR: Color = Color('cb003c')
const ENEMY_2_ARROW_COLOR: Color = Color('930029')
const ENEMY_3_ARROW_COLOR: Color = Color('74001e')
const ENEMY_4_ARROW_COLOR: Color = Color('593b1d')
const ENEMY_ARROW_HIGHLIGHTED_COLOR: Color = Color('ffa3ac')#ffa3ac
const CIVILIAN_ARROW_COLOR: Color = Color('fff700')


func toggle_visibility(is_toggled: bool) -> void:
	if not is_in_group('WORLD_ENV'):
		if is_toggled:
			show()
		else:
			hide()
	
	for child in get_children():
		if not child.is_in_group('WORLD_ENV'):
			if is_toggled:
				child.show()
			else:
				child.hide()


func on_button_disabled(button: BaseButton, is_disabled: bool) -> void:
	button.set_disabled(is_disabled)
	if is_disabled:
		button.modulate.a = 0.5
	else:
		button.modulate.a = 1.0


func push_unique_to_array(array: Array, item) -> void:
	if not array.has(item):
		array.push_back(item)


func get_vector3_on_map(position: Vector3) -> Vector3:
	return Vector3(position.x, 0.5, position.z)


func convert_spawn_coords_to_vector_coords(spawn_coords: Array) -> Array[Vector2i]:
	var vector_coords: Array[Vector2i] = []
	vector_coords.append_array(spawn_coords.map(func(coords): return Vector2i(coords.x, coords.y)))
	return vector_coords


func is_tile_adjacent_by_coords(origin_coords: Vector2i, target_coords: Vector2i) -> bool:
	return abs(origin_coords - target_coords) == Vector2i(0, 1) or abs(origin_coords - target_coords) == Vector2i(1, 0)


func is_close(value: float, target: float) -> bool:
	return absf(value - target) < 0.1


func get_hit_direction(origin_to_target_sign: Vector2i) -> HitDirection:
	if origin_to_target_sign == Vector2i(-1, 0):
		return HitDirection.DOWN_LEFT
	if origin_to_target_sign == Vector2i(1, 0):
		return HitDirection.UP_RIGHT
	if origin_to_target_sign == Vector2i(0, -1):
		return HitDirection.RIGHT_DOWN
	if origin_to_target_sign == Vector2i(0, 1):
		return HitDirection.LEFT_UP
	if origin_to_target_sign == Vector2i(-1, -1):
		return HitDirection.DOWN
	if origin_to_target_sign == Vector2i(1, 1):
		return HitDirection.UP
	if origin_to_target_sign == Vector2i(1, -1):
		return HitDirection.RIGHT
	if origin_to_target_sign == Vector2i(-1, 1):
		return HitDirection.LEFT
	return HitDirection.UNKNOWN


func is_good_hit_direction(hit_direction: HitDirection, action_direction: ActionDirection) -> bool:
	if action_direction == ActionDirection.HORIZONTAL_LINE or action_direction == ActionDirection.HORIZONTAL_DOT:
		return hit_direction == HitDirection.DOWN_LEFT or hit_direction == HitDirection.UP_RIGHT or hit_direction == HitDirection.RIGHT_DOWN or hit_direction == HitDirection.LEFT_UP
	
	if action_direction == ActionDirection.VERTICAL_LINE or action_direction == ActionDirection.VERTICAL_DOT:
		return hit_direction == HitDirection.DOWN or hit_direction == HitDirection.UP or hit_direction == HitDirection.RIGHT or hit_direction == HitDirection.LEFT
	
	return false


func get_character_color(character: Character) -> Color:
	if character.is_in_group('PLAYERS'): return PLAYER_ARROW_COLOR
	if character.is_in_group('ENEMIES'): return character.arrow_color
	if character.is_in_group('CIVILIANS'): return CIVILIAN_ARROW_COLOR
	return Color.BLACK


#static func get_action(action_id: ActionType) -> ActionObject:
	#return Global.all_actions.filter(func(action): return action.id == action_id).front()


static func get_selected_player(selected_player_id: PlayerType) -> PlayerObject:
	return Global.selected_players.filter(func(selected_player): return selected_player.id == selected_player_id).front()


static func get_selected_enemy(selected_enemy_id: EnemyType) -> EnemyObject:
	return Global.selected_enemies.filter(func(selected_enemy): return selected_enemy.id == selected_enemy_id).front()


static func get_selected_civilian(selected_civilian_id: CivilianType) -> CivilianObject:
	return Global.selected_civilians.filter(func(selected_civilian): return selected_civilian.id == selected_civilian_id).front()


static func get_item(item_id: ItemType) -> ItemObject:
	return Global.all_items.filter(func(item): return item.id == item_id).front()


static func get_selected_item(selected_item_id: ItemType) -> ItemObject:
	return Global.selected_items.filter(func(selected_item): return selected_item.id == selected_item_id).front()
