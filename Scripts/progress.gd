extends Util

@onready var menu: Menu = $/root/Menu
@onready var game_state_manager: GameStateManager = $/root/Main/GameStateManager
@onready var upgrades_container = $CanvasLayer/PanelCenterContainer/UpgradesContainer
@onready var upgrades_label = $CanvasLayer/PanelCenterContainer/UpgradesContainer/UpgradesLabel
@onready var upgrades_grid_container = $CanvasLayer/PanelCenterContainer/UpgradesContainer/UpgradesGridContainer
@onready var upgrades_next_button = $CanvasLayer/PanelCenterContainer/UpgradesContainer/UpgradesButtonsHBoxContainer/UpgradesNextButton
@onready var upgrades_skip_button = $CanvasLayer/PanelCenterContainer/UpgradesContainer/UpgradesButtonsHBoxContainer/UpgradesSkipButton
@onready var levels_container = $CanvasLayer/PanelCenterContainer/LevelsContainer
@onready var levels_next_button = $CanvasLayer/PanelCenterContainer/LevelsContainer/LevelsNextButton

var player_1_texture: CompressedTexture2D = preload('res://Icons/player1.png')
var player_2_texture: CompressedTexture2D = preload('res://Icons/player2.png')
var player_3_texture: CompressedTexture2D = preload('res://Icons/player3.png')

var selected_upgrade_id: int
var selected_level_type: LevelType


func _ready() -> void:
	Global.engine_mode = Global.EngineMode.MENU
	
	if Global.loot_size > 0:
		upgrades_container.show()
		levels_container.hide()
	else:
		upgrades_container.hide()
		levels_container.show()
	
	upgrades_label.text = 'If you have 3+ loot, you can upgrade damage of a single player\nCurrent loot: ' + str(Global.loot_size)
	upgrades_next_button.set_disabled(true)
	upgrades_skip_button.set_disabled(false)
	levels_next_button.set_disabled(true)
	
	init_ui()


func init_ui():
	for default_upgrade_container in upgrades_grid_container.get_children().filter(func(child): return child.is_in_group('ALWAYS_FREE')):
		default_upgrade_container.queue_free()
	
	assert(Global.selected_players.size() > 0 and Global.selected_players.size() <= 3, 'Too few or too many selected players')
	# show available upgrades only for not already upgraded players
	for selected_player in Global.selected_players.filter(func(selected_player): return not selected_player.is_damage_upgraded):
		var player_texture
		# tutorial and first scene
		if selected_player.id == 0 or selected_player.id == 1:
			player_texture = player_1_texture
		elif selected_player.id == 2:
			player_texture = player_2_texture
		elif selected_player.id == 3:
			player_texture = player_3_texture
		
		var upgrade_container = VBoxContainer.new()
		upgrade_container.name = 'Upgrade' + str(selected_player.id) + 'Container'
		
		var upgrade_texture_button = TextureButton.new()
		upgrade_texture_button.connect('toggled', _on_upgrade_texture_button_toggled.bind(selected_player.id - 1))
		upgrade_texture_button.name = 'Upgrade' + str(selected_player.id) + 'TextureButton'
		upgrade_texture_button.toggle_mode = true
		upgrade_texture_button.texture_normal = player_texture
		upgrade_texture_button.modulate.a = 0.5
		upgrade_texture_button.set_disabled(Global.loot_size < 3)
		
		var upgrade_label = Label.new()
		upgrade_label.name = 'Upgrade' + str(selected_player.id) + 'Label'
		# hardcoded
		upgrade_label.text = 'DAMAGE: ' + str(selected_player.damage) + ' -> ' + str(selected_player.damage_upgraded)
		
		upgrade_container.add_child(upgrade_texture_button)
		upgrade_container.add_child(upgrade_label)
		upgrades_grid_container.add_child(upgrade_container)
		
		upgrade_container.show()


func show_back() -> void:
	Global.engine_mode = Global.EngineMode.MENU
	
	toggle_visibility(true)


func _on_menu_button_pressed() -> void:
	toggle_visibility(false)
	
	menu.show_in_game_menu(self)


func _on_upgrade_texture_button_toggled(toggled_on: bool, index: int) -> void:
	# first disable all upgrades
	for upgrade_container in upgrades_grid_container.get_children():
		# hardcoded
		var upgrade_texture_button = upgrade_container.get_child(0)
		upgrade_texture_button.modulate.a = 0.5
		upgrade_texture_button.set_pressed_no_signal(false)
	
	# then enable selected upgrade
	if toggled_on:
		var upgrade_container = upgrades_grid_container.get_child(index)
		# hardcoded
		var upgrade_texture_button = upgrade_container.get_child(0)
		upgrade_texture_button.modulate.a = 1.0
		upgrade_texture_button.set_pressed_no_signal(true)
		
		selected_upgrade_id = index + 1
	else:
		selected_upgrade_id = -1
	
	upgrades_next_button.set_disabled(selected_upgrade_id <= 0)


func _on_upgrades_next_button_pressed():
	var selected_upgrade_player = Global.selected_players.filter(func(selected_player): return selected_player.id == selected_upgrade_id).front()
	#selected_upgrade_player.damage = selected_upgrade_player.damage_upgraded
	selected_upgrade_player.is_damage_upgraded = true
	
	Global.loot_size -= 3
	
	upgrades_container.hide()
	levels_container.show()


func _on_upgrades_skip_button_pressed():
	upgrades_container.hide()
	levels_container.show()


func _on_level_type_button_pressed(level_type: LevelType) -> void:
	selected_level_type = level_type
	
	levels_next_button.set_disabled(not selected_level_type)


func _on_levels_next_button_pressed():
	game_state_manager.get_parent().toggle_visibility(true)
	game_state_manager.init_by_level_type(selected_level_type)
	
	queue_free()
