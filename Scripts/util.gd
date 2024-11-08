extends Node3D

class_name Util

enum ActionDirection {HORIZONTAL_LINE, VERTICAL_LINE, HORIZONTAL_DOT, VERTICAL_DOT, NONE = -1}
enum ActionType {PUSH_BACK, PULL_FRONT, MISS_MOVE, MISS_ACTION, HIT_ALLY, GIVE_SHIELD, SLOW_DOWN, CROSS_PUSH_BACK, NONE = -1}
enum StateType {MISS_MOVE, MISS_ACTION, HIT_ALLY, GIVE_SHIELD, SLOW_DOWN, NONE = -1}
enum PhaseType {MOVE, ACTION, WAIT}
enum TileType {PLAIN, GRASS, TREE, MOUNTAIN, VOLCANO, WATER, LAVA, FLOOR, HOLE}
enum TileHealthType {HEALTHY, DAMAGED, DESTROYED, DESTRUCTIBLE_HEALTHY, DESTRUCTIBLE_DAMAGED, INDESTRUCTIBLE, INDESTRUCTIBLE_WALKABLE}
enum HitDirection {DOWN_LEFT, UP_RIGHT, RIGHT_DOWN, LEFT_UP, DOWN, UP, RIGHT, LEFT}
enum LevelType {TUTORIAL, KILL_ENEMIES, SURVIVE_TURNS, SAVE_CIVILIANS, SAVE_TILES}
enum LevelEvent {MORE_ENEMIES, MINE, FALLING_MISSLE, FALLING_ROCK, FALLING_LAVA, FLOOD, MOVING_PLATFORMS, NONE = -1}

const TILE_HIGHLIGHTED_COLOR = Color('91c3ff')
const PLAYER_ARROW_COLOR: Color = Color('005fcd')
const ENEMY_1_ARROW_COLOR: Color = Color('cb003c')
const ENEMY_2_ARROW_COLOR: Color = Color('930029')
const ENEMY_3_ARROW_COLOR: Color = Color('74001e')
const ENEMY_4_ARROW_COLOR: Color = Color('593b1d')
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


func convert_spawn_coords_to_vector_coords(spawn_coords):
	return spawn_coords.map(func(coords): return Vector2i(coords.x, coords.y))


func is_tile_adjacent_by_coords(origin_coords, target_coords):
	return abs(origin_coords - target_coords) == Vector2i(0, 1) or abs(origin_coords - target_coords) == Vector2i(1, 0)


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


func get_character_color(character):
	if character.is_in_group('PLAYERS'): return PLAYER_ARROW_COLOR
	if character.is_in_group('ENEMIES'): return character.arrow_color
	if character.is_in_group('CIVILIANS'): return CIVILIAN_ARROW_COLOR
