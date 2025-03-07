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


func init(player_id: Util.PlayerType, player_texture: CompressedTexture2D, action_1_texture: CompressedTexture2D, action_2_texture: CompressedTexture2D, player_max_health: int, player_move_distance: int, item_1: ItemObject = null, item_2: ItemObject = null) -> void:
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
	
	update_health(player_max_health)
	update_move_distance(player_move_distance)
	
	action_1_texture_button.texture_normal = action_1_texture
	action_1_texture_button.texture_pressed = action_1_texture_active
	action_1_texture_button.texture_hover = action_1_texture_button.texture_pressed
	
	action_2_texture_button.texture_normal = action_2_texture
	action_2_texture_button.texture_pressed = action_2_texture_active
	action_2_texture_button.texture_hover = action_2_texture_button.texture_pressed
	
	if item_1:
		item_1_texture_button.texture_normal = AtlasTexture.new()
		item_1_texture_button.texture_normal.atlas = item_1.texture
		item_1_texture_button.texture_normal.region = Rect2(0, 0, 80, 75)
		
		item_1_texture_button.texture_pressed = AtlasTexture.new()
		item_1_texture_button.texture_pressed.atlas = item_1.texture
		item_1_texture_button.texture_pressed.region = Rect2(0, 77, 80, 79)
		
		item_1_texture_button.texture_hover = item_1_texture_button.texture_pressed
	
	if item_2:
		item_2_texture_button.texture_normal = AtlasTexture.new()
		item_2_texture_button.texture_normal.atlas = item_2.texture
		item_2_texture_button.texture_normal.region = Rect2(0, 0, 80, 75)
		
		item_2_texture_button.texture_pressed = AtlasTexture.new()
		item_2_texture_button.texture_pressed.atlas = item_2.texture
		item_2_texture_button.texture_pressed.region = Rect2(0, 77, 80, 79)
		
		item_2_texture_button.texture_hover = item_2_texture_button.texture_pressed


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
