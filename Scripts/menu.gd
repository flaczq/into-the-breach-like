extends Util

@export var main_scene: PackedScene

@onready var tutorial_check_button = $CanvasLayer/UI/VBoxContainer/TutorialCheckButton


func _ready():
	tutorial_check_button.set_pressed(Global.tutorial)


func _on_start_button_pressed():
	toggle_visibility(false)
	
	get_tree().root.add_child(main_scene.instantiate())


func _on_tutorial_check_button_toggled(toggled_on):
	Global.tutorial = toggled_on
