extends Util

signal hovered_event(tile: Node3D, is_hovered: bool)
signal clicked_event(tile: Node3D, is_clicked: bool)

@onready var area_3d = $Area3D

var is_clicked: bool = false
#var is_hovered: bool = false
var is_player_clicked: bool = false
var is_planned_enemy_action: bool = false

var tile_type: TileType
var health_type: TileHealthType
var coords: Vector2i
var player: Node3D
var enemy: Node3D
var civilian: Node3D
var model: MeshInstance3D
var model_default_color: Color

func _ready():
	area_3d.connect('mouse_entered', _on_area_3d_mouse_entered)
	area_3d.connect('mouse_exited', _on_area_3d_mouse_exited)
	area_3d.connect('input_event', _on_area_3d_input_event)
	
	# coords from name int values: x = position.z, y = position.x
	coords = Vector2i(int(name.substr(4, 1)), int(name.substr(5, 1)))


func init(tile_init_data):
	# remove default tile
	remove_child(get_child(0))
	
	model = tile_init_data.model
	add_child(model)
	
	tile_type = tile_init_data.tile_type
	health_type = tile_init_data.health_type
	#model_default_color = tile_init_data.model_default_color

	if tile_init_data.asset:
		add_child(tile_init_data.asset)
	
	#model_material = StandardMaterial3D.new()
	#model.set_surface_override_material(0, model_material)
	
	color_model(model_default_color)


func reset():
	player = null
	enemy = null
	civilian = null


func set_player(new_player):
	player = new_player


func set_enemy(new_enemy):
	enemy = new_enemy


func set_civilian(new_civilian):
	civilian = new_civilian


func is_free():
	return health_type != TileHealthType.DESTROYED and health_type != TileHealthType.INDESTRUCTIBLE and not player and not enemy and not civilian


func color_model(color):
	if color:
		model.material_override.albedo_color = color
	elif is_planned_enemy_action:
		model.material_override.albedo_color = Color.PALE_VIOLET_RED
	#else:
		#model.material_override.albedo_color = model_default_color


func toggle_player_hovered(new_is_player_hovered):
	if new_is_player_hovered:
		model.material_override.albedo_color = Color.MEDIUM_PURPLE
	else:
		color_model(null)


func toggle_player_clicked(new_is_player_clicked):
	is_player_clicked = new_is_player_clicked
	
	if is_player_clicked:
		model.material_override.albedo_color = Color.PURPLE
	else:
		color_model(null)


func set_planned_enemy_action(new_is_planned_enemy_action):
	is_planned_enemy_action = new_is_planned_enemy_action
	
	color_model(null)


func get_shot(taken_damage, action_type, origin_tile_coords):
	if player:
		await player.get_shot(taken_damage, action_type, origin_tile_coords)
	elif enemy:
		await enemy.get_shot(taken_damage, action_type, origin_tile_coords)
	elif civilian:
		await civilian.get_shot(taken_damage, action_type, origin_tile_coords)
	else:
		# TODO maybe apply_action_type()?
		if taken_damage > 0:
			if health_type == TileHealthType.HEALTHY:
				health_type = TileHealthType.DAMAGED
				
				model_default_color = Color.INDIAN_RED
				model.material_override.albedo_color = model_default_color
				print('ttile ' + str(coords) + ' -> damaged tile')
			elif health_type == TileHealthType.DAMAGED:
				health_type = TileHealthType.DESTROYED
				
				model_default_color = Color.RED
				model.material_override.albedo_color = model_default_color
				print('ttile ' + str(coords) + ' -> destroyed')
			elif health_type == TileHealthType.DESTROYED:
				print('ttile ' + str(coords) + ' -> already destroyed, nothing happens')
			elif health_type == TileHealthType.INDESTRUCTIBLE:
				print('ttile ' + str(coords) + ' -> indestructible, nothing happens')
		else:
			print('ttile ' + str(coords) + ' -> used action on empty tile, nothing happens')


func _on_area_3d_mouse_entered():
	hovered_event.emit(self, true)
		
	if is_player_clicked:
		#is_hovered = true
		
		model.material_override.albedo_color = Color.WEB_PURPLE
		
		#hovered_event.emit(self, true)
	elif player:
		player.on_mouse_entered()


func _on_area_3d_mouse_exited():
	hovered_event.emit(self, false)
	
	if is_player_clicked:
		#is_hovered = false
		
		model.material_override.albedo_color = Color.PURPLE
		
		#hovered_event.emit(self, false)
	elif player:
		player.on_mouse_exited()


func _on_area_3d_input_event(camera, event, position, normal, shape_idx):
	#if health_type == TileHealthType.DESTROYED or health_type == TileHealthType.INDESTRUCTIBLE:
		#return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_clicked = not is_clicked
		
		clicked_event.emit(self, is_clicked)
