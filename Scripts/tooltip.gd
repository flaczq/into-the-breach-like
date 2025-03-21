extends Control

class_name Tooltip

@onready var tooltip_panel = $TooltipPanelContainer
@onready var tooltip_label = $TooltipPanelContainer/TooltipLabel


func _ready() -> void:
	hide()


func show_tooltip() -> void:
	show()


func set_text(text: String) -> void:
	tooltip_label.text = text


func upgrade_action(action_type: Util.ActionType) -> void:
	pass
