extends Control

class_name ActionTooltip

@onready var action_tooltip_panel_container = $ActionTooltipPanelContainer
@onready var action_1_texture_button = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action1HBoxContainer/Action1TextureButton
@onready var action_1_label = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action1HBoxContainer/Action1Label
@onready var action_2h_box_container = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action2HBoxContainer
@onready var action_2_texture_button = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action2HBoxContainer/Action2TextureButton
@onready var action_2_label = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/Action2HBoxContainer/Action2Label
@onready var bottom_v_box_container = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/BottomVBoxContainer
@onready var change_label = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/BottomVBoxContainer/ChangeLabel
@onready var upgrade_texture_button = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/BottomVBoxContainer/UpgradeTextureButton
@onready var upgrade_label = $ActionTooltipPanelContainer/ActionTooltipVBoxContainer/BottomVBoxContainer/UpgradeTextureButton/UpgradeLabel

var clicked_action_id: Util.ActionType = Util.ActionType.NONE

var player: Player


func init(new_player: Player) -> void:
	hide()
	change_label.hide()
	
	player = new_player
	name = name.replace('X', str(player.id))
	
	action_1_label.text = player.action_1.description
	action_2_label.text = player.action_2.description
	
	if player.action_2.id == Util.ActionType.NONE:
		action_2h_box_container.hide()
	
	# player selection screen
	# FIXME ładniej
	if Global.selected_players.size() < 3:
		action_1_texture_button.set_disabled(true)
		action_2_texture_button.set_disabled(true)
		bottom_v_box_container.hide()
	
	action_tooltip_panel_container.reset_size()


func disable_upgrade_button() -> void:
	upgrade_texture_button.set_disabled(true)
	upgrade_label.set_theme_type_variation('LabelDisabled')


func _on_hidden():
	disable_upgrade_button()
	change_label.hide()
	clicked_action_id = Util.ActionType.NONE
	action_1_texture_button.set_pressed_no_signal(false)
	action_2_texture_button.set_pressed_no_signal(false)


func _on_action_1_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		clicked_action_id = player.action_1.id
		upgrade_texture_button.set_disabled(false)
		upgrade_label.set_theme_type_variation('')
		upgrade_label.text = 'UPGRADE ACTION 1'
		change_label.text = player.action_1.change_info
		change_label.show()
		action_2_texture_button.set_pressed_no_signal(false)
	else:
		clicked_action_id = Util.ActionType.NONE
		disable_upgrade_button()
		change_label.hide()


func _on_action_2_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		clicked_action_id = player.action_2.id
		upgrade_texture_button.set_disabled(false)
		upgrade_label.set_theme_type_variation('')
		upgrade_label.text = 'UPGRADE ACTION 2'
		change_label.text = player.action_2.change_info
		change_label.show()
		action_1_texture_button.set_pressed_no_signal(false)
	else:
		clicked_action_id = Util.ActionType.NONE
		disable_upgrade_button()
		change_label.hide()


func _on_upgrade_texture_button_pressed() -> void:
	assert(clicked_action_id != Util.ActionType.NONE, 'No action clicked')
	if clicked_action_id == player.action_1.id:
		player.action_1.upgrade()
	elif clicked_action_id == player.action_2.id:
		player.action_2.upgrade()
	
	print('Action ' + str(clicked_action_id) + ' upgraded!')
	hide()
