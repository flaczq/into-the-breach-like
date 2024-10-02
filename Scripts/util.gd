extends Node3D

class_name Util

enum ActionDirection {HORIZONTAL_LINE, VERTICAL_LINE, HORIZONTAL_DOT, VERTICAL_DOT, NONE = -1}
enum ActionType {PUSH_BACK, PULL_FRONT, MISS_ACTION, HIT_ALLY, GIVE_SHIELD, SLOW_DOWN, NONE = -1}
enum StateType {MISS_ACTION, HIT_ALLY, GIVE_SHIELD, SLOW_DOWN, NONE = -1}
enum PhaseType {MOVE, ACTION, WAIT}
enum TileType {PLAIN, GRASS, TREE, MOUNTAIN, VOLCANO, WATER, LAVA}
enum TileHealthType {HEALTHY, DAMAGED, DESTROYED, DESTRUCTIBLE, INDESTRUCTIBLE}
enum HitDirection {DOWN_LEFT, UP_RIGHT, RIGHT_DOWN, LEFT_UP, DOWN, UP, RIGHT, LEFT}
enum MapType {ABC, DEF, GHI, TUTORIAL = -1}

const TILE_INFO = {
	'sign_1': 'TUTORIAL HINT #1:\nTake advantage of seeing your enemy\'s attack',
	'sign_2': 'TUTORIAL HINT #2:\nSome obstacles may be destructible',
	'sign_3': 'TUTORIAL HINT #3:\nSometimes using an action instead of shooting is necessary to save a civilian',
	'sign_4': 'TUTORIAL HINT #4:\nEnemies always use their actions while dealing damage',
}


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


func get_direction(hit_direction):
	if hit_direction == Vector2i(-1, 0):
		return HitDirection.DOWN_LEFT
	if hit_direction == Vector2i(1, 0):
		return HitDirection.UP_RIGHT
	if hit_direction == Vector2i(0, -1):
		return HitDirection.RIGHT_DOWN
	if hit_direction == Vector2i(0, 1):
		return HitDirection.LEFT_UP
	if hit_direction == Vector2i(-1, -1):
		return HitDirection.DOWN
	if hit_direction == Vector2i(1, 1):
		return HitDirection.UP
	if hit_direction == Vector2i(1, -1):
		return HitDirection.RIGHT
	if hit_direction == Vector2i(-1, 1):
		return HitDirection.LEFT
