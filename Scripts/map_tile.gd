extends Util

signal hovered_event(tile: Node3D, is_hovered: bool)
signal clicked_event(tile: Node3D, is_clicked: bool)

@onready var area_3d = $Area3D

var is_clicked: bool = false
var is_hovered: bool = false
var is_player_clicked: bool = false
var is_player_hovered: bool = false
var is_planned_enemy_action: bool = false

var tile_type: TileType
var health_type: TileHealthType
var coords: Vector2i
var player: Node3D
var enemy: Node3D
var civilian: Node3D
var models: Dictionary
var model_material: StandardMaterial3D
var shader_material: ShaderMaterial


func _ready():
	area_3d.connect('mouse_entered', _on_area_3d_mouse_entered)
	area_3d.connect('mouse_exited', _on_area_3d_mouse_exited)
	area_3d.connect('input_event', _on_area_3d_input_event)
	
	# coords from name int values: x-axis = position.z, y-axis = position.x
	coords = Vector2i(int(name.substr(4, 1)), int(name.substr(5, 1)))
	
	# create new materials for each tile to make them unique
	model_material = StandardMaterial3D.new()
	shader_material = ShaderMaterial.new()


func init(tile_init_data):
	# remove default model
	remove_child(get_child(0))
	
	models = tile_init_data.models
	tile_type = tile_init_data.tile_type
	health_type = tile_init_data.health_type
	
	# setup model with texture/shader/color
	shader_material.set_shader(models.tile_shader)
	#toggle_shader(false)
	if models.has('tile_texture'):
		model_material.set_texture(0, models.tile_texture)
	elif models.has('tile_default_color'):
		model_material.albedo_color = models.tile_default_color
	
	# has to be done like this to make tiles unique
	models.tile.set_surface_override_material(1, model_material)
	
	models.tile.show()
	models.tile_highlighted.hide()
	models.tile_targeted.hide()
	models.tile_damaged.hide()
	models.tile_destroyed.hide()
	
	# add tile with all variations
	add_child(models.tile)
	add_child(models.tile_highlighted)
	add_child(models.tile_targeted)
	add_child(models.tile_damaged)
	add_child(models.tile_destroyed)
	if models.has('asset'):
		add_child(models.asset)
	
	toggle_tile_models()


func toggle_tile_models():
	#if color:
		#model_material.albedo_color = color
	#elif is_planned_enemy_action:
		#model_material.albedo_color = Color.PALE_VIOLET_RED
	#else:
		#model_material.albedo_color = model_default_color
	models.tile_highlighted.hide()
	models.tile_targeted.hide()
	models.tile_damaged.hide()
	models.tile_destroyed.hide()
	
	position.y = 0
	
	if is_player_clicked:
		models.tile_highlighted.show()
		
		if is_hovered:
			# last (target) tile in path
			position.y = 0.25
	elif is_player_hovered:
		models.tile_highlighted.show()
	
	if health_type == TileHealthType.DESTROYED:
		models.tile_destroyed.show()
		
		position.y = -0.25
	elif health_type == TileHealthType.DAMAGED:
		models.tile_damaged.show()
	
	if is_planned_enemy_action:
		models.tile_targeted.show()


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


func toggle_shader(new_is_shader):
	if new_is_shader:
		model_material.set_next_pass(shader_material)
	else:
		model_material.set_next_pass(null)


func toggle_player_hovered(new_is_player_hovered):
	is_player_hovered = new_is_player_hovered
	
	toggle_tile_models()
	
	#if new_is_player_hovered:
		##model_material.albedo_color = Color.MEDIUM_PURPLE
		##toggle_shader(true)
	#else:
		#toggle_tile_models()
		##toggle_shader(false)


func toggle_player_clicked(new_is_player_clicked):
	is_player_clicked = new_is_player_clicked
	
	toggle_tile_models()
	
	#if is_player_clicked:
		##model_material.albedo_color = Color.PURPLE
		##toggle_shader(true)
	#else:
		#toggle_tile_models()
		#toggle_shader(false)


func set_planned_enemy_action(new_is_planned_enemy_action):
	is_planned_enemy_action = new_is_planned_enemy_action
	
	toggle_tile_models()


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
			var color_tween = create_tween()
			color_tween.tween_property(model_material, 'albedo_color', model_material.albedo_color, 1.0).from(Color.RED)
			await color_tween.finished
			
			if health_type == TileHealthType.HEALTHY:
				health_type = TileHealthType.DAMAGED
				
				#models.tile_default_color = Color.INDIAN_RED
				#model_material.albedo_color = models.tile_default_color
				toggle_tile_models()
				print('ttile ' + str(coords) + ' -> damaged tile')
			elif health_type == TileHealthType.DAMAGED:
				health_type = TileHealthType.DESTROYED
				
				#models.tile_default_color = Color.RED
				#model_material.albedo_color = models.tile_default_color
				toggle_tile_models()
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
		is_hovered = true
		
		#model_material.albedo_color = Color.WEB_PURPLE
		toggle_tile_models()
		
		#hovered_event.emit(self, true)
	elif player:
		player.on_mouse_entered()


func _on_area_3d_mouse_exited():
	hovered_event.emit(self, false)
	
	if is_player_clicked:
		is_hovered = false
		
		#model_material.albedo_color = Color.PURPLE
		toggle_tile_models()
		
		#hovered_event.emit(self, false)
	elif player:
		player.on_mouse_exited()


func _on_area_3d_input_event(camera, event, position, normal, shape_idx):
	#if health_type == TileHealthType.DESTROYED or health_type == TileHealthType.INDESTRUCTIBLE:
		#return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_clicked = not is_clicked
		
		clicked_event.emit(self, is_clicked)
