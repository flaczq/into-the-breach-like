extends Node

class_name PlayerContainer

#@onready var player_texture_button = $PlayerTextureButton
#@onready var health_label = $HealthHBoxContainer/HealthLabel
#@onready var move_distance_label = $MoveDistanceHBoxContainer/MoveDistanceLabel
#@onready var damage_label = $DamageHBoxContainer/DamageLabel
#@onready var action_label = $ActionHBoxContainer/ActionLabel

var player_1_texture: CompressedTexture2D = preload('res://Icons/player1.png')
var player_2_texture: CompressedTexture2D = preload('res://Icons/player2.png')
var player_3_texture: CompressedTexture2D = preload('res://Icons/player3.png')

var id: int


func init(new_id: int, max_health: int, move_distance: int, damage: int, action_type: Util.ActionType, on_player_texture_button_mouse_entered: Callable, on_player_texture_button_mouse_exited: Callable, on_player_texture_button_toggled: Callable) -> void:
	assert(new_id >= 0, 'Wrong player object id')
	id = new_id
	
	var player_texture
	# tutorial and first scene
	if id == 0 or id == 1:
		player_texture = player_1_texture
	elif id == 2:
		player_texture = player_2_texture
	elif id == 3:
		player_texture = player_3_texture
	
	name = name.replace('X', str(id))
	
	# find_child is required instead of @onready var because of weird 'scene inheritance'
	var player_texture_button = find_child('PlayerTextureButton')
	player_texture_button.connect('mouse_entered', on_player_texture_button_mouse_entered.bind(id))
	player_texture_button.connect('mouse_exited', on_player_texture_button_mouse_exited.bind(id))
	player_texture_button.connect('toggled', on_player_texture_button_toggled.bind(id))
	player_texture_button.texture_normal = player_texture
	
	var health_label = find_child('HealthLabel')
	health_label.text = str(max_health)
	
	var move_distance_label = find_child('MoveDistanceLabel')
	move_distance_label.text = str(move_distance)
	
	var damage_label = find_child('DamageLabel')
	damage_label.text = str(damage)
	
	var action_label = find_child('ActionLabel')
	action_label.text = tr('ACTION_' + str(Util.ActionType.keys()[action_type]))
