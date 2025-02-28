extends Control

class_name PlayerStats

signal player_stats_mouse_entered(player_id: Util.PlayerType)
signal player_stats_mouse_exited(player_id: Util.PlayerType)
signal player_stats_toggled(toggled_on: bool, player_id: Util.PlayerType)

@onready var texture_rect = $TextureRect
@onready var avatar_texture_button = $TextureRect/AvatarTextureButton
@onready var health_label = $TextureRect/HealthLabel
@onready var move_distance_label = $TextureRect/MoveDistanceLabel

var id: Util.PlayerType


func init(player_id: Util.PlayerType, player_texture: CompressedTexture2D, player_health: int, player_max_health: int, player_move_distance: int) -> void:
	id = player_id
	
	avatar_texture_button.texture_normal = AtlasTexture.new()
	avatar_texture_button.texture_normal.atlas = player_texture
	avatar_texture_button.texture_normal.region = Rect2(0, 0, 143, 122)
	
	avatar_texture_button.texture_hover = AtlasTexture.new()
	avatar_texture_button.texture_hover.atlas = player_texture
	avatar_texture_button.texture_hover.region = Rect2(0, 122, 143, 142)
	
	avatar_texture_button.texture_pressed = avatar_texture_button.texture_hover
	
	update_health(player_health, player_max_health)
	update_move_distance(player_move_distance)


func update_health(player_health: int, player_max_health: int) -> void:
	health_label.text = str(player_health) + '/' + str(player_max_health)


func update_move_distance(player_move_distance: int) -> void:
	move_distance_label.text = str(player_move_distance)


func _on_avatar_texture_button_mouse_entered() -> void:
	player_stats_mouse_entered.emit(id)


func _on_avatar_texture_button_mouse_exited() -> void:
	player_stats_mouse_exited.emit(id)


func _on_avatar_texture_button_toggled(toggled_on: bool) -> void:
	player_stats_toggled.emit(toggled_on, id)
