extends Control

class_name ActionTooltip

@onready var action_tooltip_panel_container = $ActionTooltipPanelContainer
@onready var action_1_texture_button = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action1HBoxContainer/Action1TextureButton
@onready var action_1_label = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action1HBoxContainer/Action1Label
@onready var action_2h_box_container = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action2HBoxContainer
@onready var action_2_texture_button = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action2HBoxContainer/Action2TextureButton
@onready var action_2_label = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action2HBoxContainer/Action2Label
@onready var upgrade_texture_button = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/UpgradeTextureButton
@onready var upgrade_label = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/UpgradeTextureButton/UpgradeLabel

var actions_ids: Array[Util.ActionType] = [Util.ActionType.NONE, Util.ActionType.NONE]
var clicked_action_id: Util.ActionType = Util.ActionType.NONE

var id: Util.PlayerType
var two_actions: bool


func init(player_id: Util.PlayerType, action_1: ActionObject, action_2: ActionObject = null) -> void:
	hide()
	
	id = player_id
	name = name.replace('X', str(id))
	
	actions_ids[0] = action_1.id
	action_1_label.text = action_1.description
	
	two_actions = (action_2 != null and action_2.id != Util.ActionType.NONE)
	if two_actions:
		actions_ids[1] = action_2.id
		action_2_label.text = action_2.description
	else:
		action_2h_box_container.hide()
	
	action_tooltip_panel_container.reset_size()


func disable_upgrade_button() -> void:
	upgrade_texture_button.set_disabled(true)
	upgrade_label.set_theme_type_variation('LabelDisabled')


func _on_hidden():
	disable_upgrade_button()
	clicked_action_id = Util.ActionType.NONE
	action_1_texture_button.set_pressed_no_signal(false)
	if two_actions:
		action_2_texture_button.set_pressed_no_signal(false)


func _on_action_1_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		clicked_action_id = actions_ids[0]
		upgrade_texture_button.set_disabled(false)
		upgrade_label.set_theme_type_variation('')
		upgrade_label.text = 'UPGRADE ACTION 1'
		
		if two_actions:
			action_2_texture_button.set_pressed_no_signal(false)
	else:
		clicked_action_id = Util.ActionType.NONE
		disable_upgrade_button()


func _on_action_2_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		clicked_action_id = actions_ids[1]
		upgrade_texture_button.set_disabled(false)
		upgrade_label.set_theme_type_variation('')
		upgrade_label.text = 'UPGRADE ACTION 2'
		
		action_1_texture_button.set_pressed_no_signal(false)
	else:
		clicked_action_id = Util.ActionType.NONE
		disable_upgrade_button()


func _on_upgrade_texture_button_pressed() -> void:
	assert(clicked_action_id != Util.ActionType.NONE, 'No action clicked')
	print('Action ' + str(clicked_action_id) + ' upgraded!')
