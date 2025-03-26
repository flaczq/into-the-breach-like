extends Control

class_name ActionTooltip

@onready var action_tooltip_panel_container = $ActionTooltipPanelContainer
@onready var action_1_texture_button = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action1HBoxContainer/Action1TextureButton
@onready var action_1_label = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action1HBoxContainer/Action1Label
@onready var action_2h_box_container = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action2HBoxContainer
@onready var action_2_texture_button = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action2HBoxContainer/Action2TextureButton
@onready var action_2_label = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action2HBoxContainer/Action2Label
@onready var change_label = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/BottomVBoxContainer/ChangeLabel
@onready var upgrade_texture_button = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/BottomVBoxContainer/UpgradeTextureButton
@onready var upgrade_label = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/BottomVBoxContainer/UpgradeTextureButton/UpgradeLabel


var actions: Array[ActionObject] = [null, null]
var clicked_action_id: Util.ActionType = Util.ActionType.NONE

var id: Util.PlayerType
var two_actions: bool


func init(player_id: Util.PlayerType, action_1: ActionObject, action_2: ActionObject = null) -> void:
	hide()
	change_label.hide()
	
	id = player_id
	name = name.replace('X', str(id))
	
	actions[0] = action_1
	action_1_label.text = action_1.description
	
	two_actions = (action_2 != null and action_2.id != Util.ActionType.NONE)
	if two_actions:
		actions[1] = action_2
		action_2_label.text = action_2.description
	else:
		action_2h_box_container.hide()
	
	action_tooltip_panel_container.reset_size()


func disable_upgrade_button() -> void:
	upgrade_texture_button.set_disabled(true)
	upgrade_label.set_theme_type_variation('LabelDisabled')


func _on_hidden():
	disable_upgrade_button()
	change_label.hide()
	clicked_action_id = Util.ActionType.NONE
	action_1_texture_button.set_pressed_no_signal(false)
	if two_actions:
		action_2_texture_button.set_pressed_no_signal(false)


func _on_action_1_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		clicked_action_id = actions[0].id
		upgrade_texture_button.set_disabled(false)
		upgrade_label.set_theme_type_variation('')
		upgrade_label.text = 'UPGRADE ACTION 1'
		change_label.text = actions[0].change_info
		change_label.show()
		
		if two_actions:
			action_2_texture_button.set_pressed_no_signal(false)
	else:
		clicked_action_id = Util.ActionType.NONE
		disable_upgrade_button()
		change_label.hide()


func _on_action_2_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		clicked_action_id = actions[1].id
		upgrade_texture_button.set_disabled(false)
		upgrade_label.set_theme_type_variation('')
		upgrade_label.text = 'UPGRADE ACTION 2'
		change_label.text = actions[1].change_info
		change_label.show()
		
		action_1_texture_button.set_pressed_no_signal(false)
	else:
		clicked_action_id = Util.ActionType.NONE
		disable_upgrade_button()
		change_label.hide()


func _on_upgrade_texture_button_pressed() -> void:
	assert(clicked_action_id != Util.ActionType.NONE, 'No action clicked')
	var player_object = Util.get_selected_player(id) as PlayerObject
	if clicked_action_id == actions[0].id:
		player_object.action_1.upgrade()
	elif clicked_action_id == actions[1].id:
		player_object.action_2.upgrade()
	
	print('Action ' + str(clicked_action_id) + ' upgraded!')
	hide()
	print(str(Util.get_selected_player(Util.PlayerType.PLAYER_1).action_1.damage))
	print(str(Util.get_selected_player(Util.PlayerType.PLAYER_2).action_1.damage))
	print(str(Util.get_selected_player(Util.PlayerType.PLAYER_3).action_1.damage))
