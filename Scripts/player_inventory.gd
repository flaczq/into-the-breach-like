extends Control

class_name PlayerInventory

signal player_inventory_mouse_entered(player_id: Util.PlayerType)
signal player_inventory_mouse_exited(player_id: Util.PlayerType)
signal player_inventory_toggled(toggled_on: bool, player_id: Util.PlayerType)

@onready var texture_rect = $TextureRect
@onready var avatar_texture_button = $TextureRect/AvatarTextureButton
@onready var health_label = $TextureRect/HealthLabel
@onready var move_distance_label = $TextureRect/MoveDistanceLabel
@onready var item_1_texture_button = $TextureRect/Item1TextureButton
@onready var item_2_texture_button = $TextureRect/Item2TextureButton
@onready var action_1_texture_button = $TextureRect/Action1TextureButton
@onready var action_2_texture_button = $TextureRect/Action2TextureButton

var id: Util.PlayerType


func init(player_id: Util.PlayerType, player_textures: Array[CompressedTexture2D], action_1_textures: Array[CompressedTexture2D], action_2_textures: Array[CompressedTexture2D], player_max_health: int, player_move_distance: int, item_1: ItemObject = null, item_2: ItemObject = null) -> void:
	texture_rect.scale = Vector2(0.75, 0.75)
	
	id = player_id
	name = name.replace('X', str(id))
	
	assert(player_textures.size() == 2, 'Wrong player textures size')
	avatar_texture_button.texture_normal = player_textures[0]
	avatar_texture_button.texture_pressed = player_textures[1]
	avatar_texture_button.texture_hover = player_textures[1]
	
	update_health(player_max_health)
	update_move_distance(player_move_distance)
	
	assert(action_1_textures.size() == 2, 'Wrong action 1 textures size')
	action_1_texture_button.texture_normal = action_1_textures[0]
	#action_1_texture_button.texture_pressed = action_1_textures[1]
	action_1_texture_button.texture_hover = action_1_textures[1]
	
	assert(action_2_textures.size() == 2, 'Wrong action 2 textures size')
	action_2_texture_button.texture_normal = action_2_textures[0]
	#action_2_texture_button.texture_pressed = action_2_textures[1]
	action_2_texture_button.texture_hover = action_2_textures[1]
	
	if item_1:
		assert(item_1.textures.size() == 2, 'Wrong item 1 textures size')
		item_1_texture_button.texture_normal = item_1.textures[0]
		item_1_texture_button.texture_pressed = item_1.textures[1]
		item_1_texture_button.texture_hover = item_1.textures[1]
	
	if item_2:
		assert(item_2.textures.size() == 2, 'Wrong item 2 textures size')
		item_2_texture_button.texture_normal = item_2.textures[0]
		item_2_texture_button.texture_pressed = item_2.textures[1]
		item_2_texture_button.texture_hover = item_2.textures[1]


func update_health(player_max_health: int) -> void:
	health_label.text = str(player_max_health)


func update_move_distance(player_move_distance: int) -> void:
	move_distance_label.text = str(player_move_distance)


func _on_avatar_texture_button_mouse_entered() -> void:
	player_inventory_mouse_entered.emit(id)


func _on_avatar_texture_button_mouse_exited() -> void:
	player_inventory_mouse_exited.emit(id)


func _on_avatar_texture_button_toggled(toggled_on: bool) -> void:
	player_inventory_toggled.emit(toggled_on, id)
