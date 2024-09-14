extends Node3D

class_name Util

enum ActionDirection {HORIZONTAL_LINE, VERTICAL_LINE, HORIZONTAL_DOT, VERTICAL_DOT, NONE = -1}
enum ActionType {PUSH_BACK, PULL_FRONT, MISS_ACTION, HIT_ALLY, GIVE_SHIELD, SLOW_DOWN, NONE = -1}
enum StateType {MISS_ACTION, HIT_ALLY, GIVE_SHIELD, SLOW_DOWN, NONE = -1}
enum PhaseType {MOVE, ACTION, WAIT}
#enum OrderType {ENVIRONMENTS, ENEMIES, PLAYERS}
enum TileType {PLAIN, GRASS, TREE, MOUNTAIN, WATER, LAVA}
enum TileHealthType {HEALTHY, DAMAGED, DESTROYED, INDESTRUCTIBLE}


func push_unique_to_array(array, item):
	if not array.has(item):
		array.push_back(item)
