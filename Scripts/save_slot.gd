extends Control

class_name SaveSlot

@onready var name_text_edit					= $TextureRect/MarginContainer/VBoxContainer/NameHBoxContainer/NameTextEdit
@onready var save_id_label					= $TextureRect/MarginContainer/HBoxContainer/LeftVBoxContainer/IdLabel
@onready var save_unlocked_players_label	= $TextureRect/MarginContainer/HBoxContainer/LeftVBoxContainer/UnlockedPlayersLabel
@onready var save_created_label				= $TextureRect/MarginContainer/HBoxContainer/RightVBoxContainer/CreatedLabel
@onready var save_play_time_label			= $TextureRect/MarginContainer/HBoxContainer/RightVBoxContainer/PlayTimeLabel

var save_object: SaveObject


func init(new_save_object: SaveObject) -> void:
	# TODO load
	save_object = new_save_object
	name = name.replace('X', str(save_object.id))
	
	update_ui()


func update_ui() -> void:
	save_id_label.text = 'ID: ' + str(save_object.id)
	save_unlocked_players_label.text = 'UNLOCKED PLAYERS: ' + str(save_object.unlocked_player_ids.size())
	save_created_label.text = 'CREATED: ' + Time.get_datetime_string_from_system()
	# FIXME
	save_play_time_label.text = 'PLAY TIME: ' + '1:25H'


func _on_save_button_pressed() -> void:
	# TODO
	save_object.description = name_text_edit.text
	Global.save = save_object
