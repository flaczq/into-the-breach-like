extends Control

class_name SaveSlot

signal slot_clicked(save_object_id: int)

@onready var name_text_edit			= $TextureRect/MarginContainer/VBoxContainer/NameHBoxContainer/NameTextEdit
@onready var id_label				= $TextureRect/MarginContainer/VBoxContainer/HBoxContainer/LeftVBoxContainer/IdLabel
@onready var unlocked_players_label	= $TextureRect/MarginContainer/VBoxContainer/HBoxContainer/LeftVBoxContainer/UnlockedPlayersLabel
@onready var created_label			= $TextureRect/MarginContainer/VBoxContainer/HBoxContainer/RightVBoxContainer/CreatedLabel
@onready var play_time_label		= $TextureRect/MarginContainer/VBoxContainer/HBoxContainer/RightVBoxContainer/PlayTimeLabel

var save_object: SaveObject


func init(new_save_object: SaveObject) -> void:
	save_object = new_save_object
	name = name.replace('X', str(save_object.id))
	
	update_ui()


func update_ui() -> void:
	name_text_edit.text = 'DEFAULT NAME ' + str(save_object.id)
	id_label.text = 'ID: ' + str(save_object.id)
	unlocked_players_label.text = 'UNLOCKED PLAYERS: ' + str(save_object.unlocked_player_ids.size())
	created_label.text = 'CREATED: ' + save_object.created
	play_time_label.text = 'PLAY TIME: ' + str(save_object.play_time)
	if save_object.created == '':
		created_label.hide()
	if save_object.play_time == 0:
		play_time_label.hide()


func _on_name_text_edit_text_changed() -> void:
	save_object.created = Time.get_datetime_string_from_system()
	save_object.updated = Time.get_datetime_string_from_system()
	save_object.description = name_text_edit.text
	
	slot_clicked.emit(save_object.id)


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_name_text_edit_text_changed()
