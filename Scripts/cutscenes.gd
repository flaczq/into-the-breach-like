extends Node

class_name Cutscenes

@onready var menu: Menu		= $/root/Menu
@onready var cutscene_label	= $PanelBottomContainer/BottomMarginContainer/CutsceneTextureRect/CutsceneMarginContainer/CutsceneLabel

var id: int


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		skip()


func init(new_id: int) -> void:
	id = new_id
	
	# TODO
	match id:
		1: cutscene_label.text = 'First'
		_: cutscene_label.text = 'Last'


func skip() -> void:
	menu.show_players_selection()
	menu.toggle_visibility(true)
	
	queue_free()
