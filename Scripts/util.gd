extends Node3D

class_name Util

enum ActionDirection {HORIZONTAL_LINE, VERTICAL_LINE, HORIZONTAL_DOT, VERTICAL_DOT, NONE = -1}
enum ActionType {PUSH_BACK, PULL_FRONT, MISS_MOVE, MISS_ACTION, HIT_ALLY, GIVE_SHIELD, SLOW_DOWN, CROSS_PUSH_BACK, NONE = -1}
enum PassiveType {HEALING, NONE = -1}
enum StateType {MISS_MOVE, MISS_ACTION, HIT_ALLY, GIVE_SHIELD, SLOW_DOWN, NONE = -1}
enum PhaseType {MOVE, ACTION, WAIT}
enum TileType {PLAIN, GRASS, TREE, MOUNTAIN, VOLCANO, WATER, LAVA, FLOOR, HOLE}
enum TileHealthType {HEALTHY, DAMAGED, DESTROYED, DESTRUCTIBLE_HEALTHY, DESTRUCTIBLE_DAMAGED, INDESTRUCTIBLE, INDESTRUCTIBLE_WALKABLE}
enum HitDirection {DOWN_LEFT, UP_RIGHT, RIGHT_DOWN, LEFT_UP, DOWN, UP, RIGHT, LEFT, UNKNOWN = -1}
enum LevelType {TUTORIAL, KILL_ENEMIES, SURVIVE_TURNS, SAVE_CIVILIANS, SAVE_TILES}
enum LevelEvent {ENEMIES_FROM_BELOW, ENEMIES_FROM_ABOVE, MINE, FALLING_MISSLE, FALLING_ROCK, FALLING_LAVA, FLOOD, MOVING_PLATFORMS, NONE = -1}

const TILE_HIGHLIGHTED_COLOR = Color('91c3ff')
const PLAYER_ARROW_COLOR: Color = Color('005fcd')
const ENEMY_1_ARROW_COLOR: Color = Color('cb003c')
const ENEMY_2_ARROW_COLOR: Color = Color('930029')
const ENEMY_3_ARROW_COLOR: Color = Color('74001e')
const ENEMY_4_ARROW_COLOR: Color = Color('593b1d')
const ENEMY_ARROW_HIGHLIGHTED_COLOR: Color = Color('ffa3ac')#ffa3ac
const CIVILIAN_ARROW_COLOR: Color = Color('fff700')


func toggle_visibility(is_toggled: bool) -> void:
	if is_toggled:
		show()
	else:
		hide()
	
	for child in get_children():
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


func get_character_color(character: Character) -> Color:
	if character.is_in_group('PLAYERS'): return PLAYER_ARROW_COLOR
	if character.is_in_group('ENEMIES'): return character.arrow_color
	if character.is_in_group('CIVILIANS'): return CIVILIAN_ARROW_COLOR
	return Color.BLACK
