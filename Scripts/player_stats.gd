extends Control

class_name PlayerStats

@onready var life_label = $TextureRect/LifeLabel
@onready var movement_label = $TextureRect/MovementLabel

var id: Util.PlayerType


func init(player: Player) -> void:
	id = player.id
	
	life_label.text = str(player.health) + '/' + str(player.max_health)
	movement_label.text = str(player.move_distance)
