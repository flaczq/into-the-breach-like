extends Control

class_name Tooltip

@onready var tooltip_panel = $TooltipPanelContainer
@onready var tooltip_label = $TooltipPanelContainer/TooltipLabel
@onready var action_1h_box_container = $TooltipPanelContainer/TooltipVBoxContainer/Action1HBoxContainer
@onready var action_2h_box_container = $TooltipPanelContainer/TooltipVBoxContainer/Action2HBoxContainer
@onready var upgrade_texture_button = $TooltipPanelContainer/TooltipVBoxContainer/UpgradeTextureButton
@onready var upgrade_label = $TooltipPanelContainer/TooltipVBoxContainer/UpgradeTextureButton/UpgradeLabel

var id: Util.PlayerType
var actions_ids: Array[Util.ActionType] = [Util.ActionType.NONE, Util.ActionType.NONE]
var clicked_action_id: Util.ActionType = Util.ActionType.NONE


func init(player_id: Util.PlayerType, action_1: ActionObject, action_2: ActionObject = null) -> void:
	hide()
	disable_upgrade_button()
	
	id = player_id
	name = name.replace('X', str(id))
	
	if not action_2:
		action_2h_box_container.hide()


func set_text(text: String) -> void:
	tooltip_label.text = text


func disable_upgrade_button() -> void:
	upgrade_texture_button.set_disabled(true)
	upgrade_label.set_theme_type_variation('LabelDisabled')


func _on_action_1_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		clicked_action_id = actions_ids[0]
		upgrade_texture_button.set_disabled(false)
		upgrade_label.set_theme_type_variation(null)
	else:
		clicked_action_id = Util.ActionType.NONE
		disable_upgrade_button()


func _on_action_2_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		clicked_action_id = actions_ids[1]
		upgrade_texture_button.set_disabled(false)
		upgrade_label.set_theme_type_variation(null)
	else:
		clicked_action_id = Util.ActionType.NONE
		disable_upgrade_button()


func _on_upgrade_button_pressed() -> void:
	assert(clicked_action_id != Util.ActionType.NONE, 'No action clicked')
	print('Action ' + str(clicked_action_id) + ' upgraded!')
