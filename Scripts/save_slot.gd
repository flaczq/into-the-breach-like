extends Control

class_name SaveSlot


var save: SaveObject


func init(new_save: Player, show_actions: bool = false) -> void:
	name = name.replace('X', str(save.id))
