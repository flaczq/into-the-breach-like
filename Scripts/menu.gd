extends Node3D

@export var main_scene: PackedScene
@onready var tutorial_check_button = $CanvasLayer/UI/VBoxContainer/TutorialCheckButton


func _ready():
	tutorial_check_button.set_pressed(Global.tutorial)


func _on_start_button_pressed():
	get_tree().change_scene_to_packed(main_scene)


func _on_tutorial_check_button_toggled(toggled_on):
	Global.tutorial = toggled_on
