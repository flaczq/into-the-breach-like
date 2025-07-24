extends Control

class_name PlayerStats

signal player_stats_mouse_entered(player_id: Util.PlayerType)
signal player_stats_mouse_exited(player_id: Util.PlayerType)
signal player_stats_toggled(toggled_on: bool, player_id: Util.PlayerType)

@onready var texture_rect			= $TextureRect
@onready var avatar_texture_button	= $TextureRect/AvatarTextureButton
@onready var health_label			= $TextureRect/HealthLabel
@onready var move_distance_label	= $TextureRect/MoveDistanceLabel

var player: Player


func init(new_player: Player) -> void:
	#texture_rect.scale = Vector2(0.75, 0.75)
	
	player = new_player
	name = name.replace('X', str(player.id))
	
	assert(player.textures.size() == 3, 'Wrong player textures size')
	avatar_texture_button.texture_normal = player.textures[0]
	avatar_texture_button.texture_pressed = player.textures[1]
	avatar_texture_button.texture_hover = player.textures[2]
	avatar_texture_button.texture_disabled = player.textures[0]
	avatar_texture_button.texture_focused = player.textures[2]
	
	update_stats()


func update_stats() -> void:
	update_health()
	update_move_distance()


func update_health() -> void:
	health_label.text = str(player.health) + '/' + str(player.max_health)


func update_move_distance() -> void:
	move_distance_label.text = str(player.move_distance)


func _on_avatar_texture_button_mouse_entered() -> void:
	if player:
		player_stats_mouse_entered.emit(player.id)


func _on_avatar_texture_button_mouse_exited() -> void:
	if player:
		player_stats_mouse_exited.emit(player.id)


func _on_avatar_texture_button_toggled(toggled_on: bool) -> void:
	if player:
		player_stats_toggled.emit(toggled_on, player.id)
