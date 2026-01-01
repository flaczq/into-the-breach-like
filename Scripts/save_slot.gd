extends Control

class_name SaveSlot

signal slot_hovered(save_object_id: int, is_hovered: bool)
signal slot_clicked(save_object_id: int)

@onready var name_label				= $TextureRect/MarginContainer/VBoxContainer/NameHBoxContainer/NameLabel
@onready var id_label				= $TextureRect/MarginContainer/VBoxContainer/HBoxContainer/LeftVBoxContainer/IdLabel
@onready var unlocked_players_label	= $TextureRect/MarginContainer/VBoxContainer/HBoxContainer/LeftVBoxContainer/UnlockedPlayersLabel
@onready var created_label			= $TextureRect/MarginContainer/VBoxContainer/HBoxContainer/RightVBoxContainer/CreatedLabel
@onready var play_time_label		= $TextureRect/MarginContainer/VBoxContainer/HBoxContainer/RightVBoxContainer/PlayTimeLabel

var save_object: SaveObject


func init(new_save_object: SaveObject) -> void:
	save_object = new_save_object
	name = name.replace('X', str(save_object.id))
	
	if Global.settings.selected_save_index > 0 and Global.saves[Global.settings.selected_save_index].id == save_object.id:
		modulate.a = 1.0
	else:
		modulate.a = 0.5
	
	update_ui()


func update_ui() -> void:
	name_label.text = 'NAME: DEFAULT NAME ' + str(save_object.id)
	id_label.text = 'ID: ' + str(save_object.id)
	unlocked_players_label.text = 'UNLOCKED PLAYERS: ' + str(save_object.unlocked_player_ids.size())
	created_label.text = 'CREATED: ' + save_object.created
	var play_time_hours = save_object.play_time / (60 * 60)
	var play_time_without_hours = (save_object.play_time - play_time_hours * (60 * 60))
	var play_time_minutes = play_time_without_hours / 60
	var play_time_seconds = play_time_without_hours % 60
	play_time_label.text = 'PLAY TIME: ' + ('%02d:%02d:%02d' % [play_time_hours, play_time_minutes, play_time_seconds])
	#if save_object.created == '-':
		#created_label.hide()
	#if save_object.play_time == 0:
		#play_time_label.hide()


func _on_texture_rect_mouse_entered() -> void:
	slot_hovered.emit(save_object.id, true)


func _on_texture_rect_mouse_exited() -> void:
	slot_hovered.emit(save_object.id, false)


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		save_object.description = name_label.text
		save_object.created = Time.get_datetime_string_from_system()
		save_object.updated = Time.get_datetime_string_from_system()
		#save_object.save_enabled = true
		
		slot_clicked.emit(save_object.id)
