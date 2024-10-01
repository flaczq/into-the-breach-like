extends Util

@onready var tutorial_check_button = $CanvasLayer/UI/VBoxContainer/TutorialCheckButton

const MAIN = preload("res://Scenes/main.tscn")

var main_scene: Node = MAIN.instantiate()


func _ready():
	tutorial_check_button.set_pressed(Global.tutorial)


func _on_start_button_pressed():
	toggle_visibility(false)
	
	if not main_scene or main_scene.is_queued_for_deletion():
		main_scene = MAIN.instantiate()
	
	get_tree().root.add_child(main_scene)


func _on_tutorial_check_button_toggled(toggled_on):
	Global.tutorial = toggled_on
