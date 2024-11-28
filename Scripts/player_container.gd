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


func init(player_object: PlayerObject, on_player_texture_button_toggled: Callable):
	assert(player_object.id >= 1, 'Wrong player object id')
	var player_texture
	# tutorial and first scene
	if player_object.id == 0 or player_object.id == 1:
		player_texture = player_1_texture
	elif player_object.id == 2:
		player_texture = player_2_texture
	elif player_object.id == 3:
		player_texture = player_3_texture
	
	name = name.replace('X', str(player_object.id))
	
	# find_child is required instead of @onready var because of weird 'scene inheritance'
	var player_texture_button = find_child('PlayerTextureButton')
	player_texture_button.connect('toggled', on_player_texture_button_toggled.bind(player_object.id - 1))
	player_texture_button.texture_normal = player_texture
	
	var health_label = find_child('HealthLabel')
	health_label.text = str(player_object.max_health)
	
	var move_distance_label = find_child('MoveDistanceLabel')
	move_distance_label.text = str(player_object.move_distance)
	
	var damage_label = find_child('DamageLabel')
	damage_label.text = str(player_object.damage)
	
	var action_label = find_child('ActionLabel')
	action_label.text = tr('ACTION_' + str(Util.ActionType.keys()[player_object.action_type]))
