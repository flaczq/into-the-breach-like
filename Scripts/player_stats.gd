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
	#scale = Vector2(0.25, 0.25)
	texture_rect.scale = Vector2(0.75, 0.75)
	
	id = player_id
	name = name.replace('X', str(id))
	
	avatar_texture_button.texture_normal = AtlasTexture.new()
	avatar_texture_button.texture_normal.atlas = player_texture
	avatar_texture_button.texture_normal.region = Rect2(0, 0, 143, 122)
	
	avatar_texture_button.texture_pressed = AtlasTexture.new()
	avatar_texture_button.texture_pressed.atlas = player_texture
	avatar_texture_button.texture_pressed.region = Rect2(0, 122, 143, 142)
	
	avatar_texture_button.texture_hover = avatar_texture_button.texture_pressed
	
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
