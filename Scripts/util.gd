extends Node3D

class_name Util

enum ActionDirection {HORIZONTAL_LINE, VERTICAL_LINE, HORIZONTAL_DOT, VERTICAL_DOT, NONE = -1}
enum ActionType {PUSH_BACK, PULL_FRONT, MISS_ACTION, HIT_ALLY, GIVE_SHIELD, SLOW_DOWN, NONE = -1}
enum StateType {MISS_ACTION, HIT_ALLY, GIVE_SHIELD, SLOW_DOWN, NONE = -1}
enum PhaseType {MOVE, ACTION, WAIT}
enum TileType {PLAIN, GRASS, TREE, MOUNTAIN, VOLCANO, WATER, LAVA}
enum TileHealthType {HEALTHY, DAMAGED, DESTROYED, DESTRUCTIBLE, INDESTRUCTIBLE, INDESTRUCTIBLE_WALKABLE}
enum HitDirection {DOWN_LEFT, UP_RIGHT, RIGHT_DOWN, LEFT_UP, DOWN, UP, RIGHT, LEFT}
enum LevelType {KILL_ENEMIES, SAVE_CIVILIANS, SURVIVE_TIL_LAST_TURN, TUTORIAL = -1}
enum PlayerType {FIRST, SECOND, THIRD, DEFAULT = -1}

const TILE_HIGHLIGHTED_COLOR = Color('91c3ff')
const PLAYER_ARROW_COLOR: Color = Color('005fcd')
const ENEMY_ARROW_COLOR: Color = Color('cb003c')
const ENEMY_ARROW_HIGHLIGHTED_COLOR: Color = Color('ffa3ac')#ffa3ac
const CIVILIAN_ARROW_COLOR: Color = Color('fff700')


func toggle_visibility(is_toggled):
	if is_toggled:
		show()
	else:
		hide()
	
	for child in get_children():
		if is_toggled:
			child.show()
		else:
			child.hide()


func push_unique_to_array(array, item):
	if not array.has(item):
		array.push_back(item)


func get_vector3_on_map(position):
	return Vector3(position.x, 0.5, position.z)


func is_close(value, target):
	return absf(value - target) < 0.1


func get_hit_direction(origin_to_target_sign):
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
