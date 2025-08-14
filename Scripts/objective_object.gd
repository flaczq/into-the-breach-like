extends Node

class_name ObjectiveObject

var type: Util.LevelObjective
var description: String
var money: int
var optional: bool
var done: bool


func init_by_type(new_type: Util.LevelObjective, new_optional: bool = false, new_done: bool = false) -> void:
	type = new_type
	optional = new_optional
	done = new_done
	
	match type:
		Util.LevelObjective.JUST_WIN:
			description = 'Just win'
			money = 1
		Util.LevelObjective.LESS_THAN_HALF_TILES_DAMAGED:
			description = 'Damage less than half the tiles'
			money = 2
		Util.LevelObjective.ALL_ENEMIES_DEAD:
			description = 'Kill all enemies'
			money = 2
		Util.LevelObjective.NO_PLAYERS_DEAD:
			description = 'Survive with all players'
			money = 2
		Util.LevelObjective.NO_CIVILIANS_DEAD:
			description = 'Don\'t let any civilians die'
			money = 3
	
	if optional:
		description += ' (optional)'
