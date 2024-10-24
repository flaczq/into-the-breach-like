extends Util

signal hovered_event(tile: Node3D, is_hovered: bool)
signal clicked_event(tile: Node3D)
signal action_cross_push_back(target_tile_coords: Vector2i, action_damage: int, origin_tile_coords: Vector2i)

@onready var area_3d = $Area3D

var is_hovered: bool = false
var is_player_clicked: bool = false
var is_player_hovered: bool = false
var is_planned_enemy_action: bool = false
var can_spawn_player: bool = false
var can_spawn_enemy: bool = false
var can_spawn_civilian: bool = false

var models: Dictionary
var model_material: StandardMaterial3D
var shader_material: ShaderMaterial
var tile_type: TileType
var health_type: TileHealthType
var info: String
var coords: Vector2i
var player: Node3D
var ghost: Node3D
var enemy: Node3D
var civilian: Node3D


func _ready():
	area_3d.connect('mouse_entered', _on_area_3d_mouse_entered)
	area_3d.connect('mouse_exited', _on_area_3d_mouse_exited)
	area_3d.connect('input_event', _on_area_3d_input_event)
	
	# coords from name int values: x-axis = position.z, y-axis = position.x
	coords = Vector2i(int(name.substr(4, 1)), int(name.substr(5, 1)))
	
	model_material = StandardMaterial3D.new()
	shader_material = ShaderMaterial.new()


func init(tile_init_data):
	# remove default model
	get_child(0).queue_free()
	
	models = tile_init_data.models
	tile_type = tile_init_data.tile_type
	health_type = tile_init_data.health_type
	
	# setup model with texture/shader/color
	shader_material.set_shader(models.tile_shader)
	toggle_shader(false)
	
	if models.get('tile_texture'):
		model_material.set_texture(0, models.tile_texture)
	elif models.get('tile_default_color'):
		model_material.albedo_color = models.tile_default_color
	
	# surface: 0 = ground, 1 = grass
	models.tile.set_surface_override_material(1, model_material)
	
	models.tile.show()
	models.tile_highlighted.hide()
	models.tile_targeted.hide()
	models.tile_damaged.hide()
	models.tile_destroyed.hide()
	models.indicator_solid.hide()
	models.indicator_dashed.hide()
	models.indicator_corners.hide()
	
	# add tile with all variations
	add_child(models.tile)
	add_child(models.tile_highlighted)
	add_child(models.tile_targeted)
	add_child(models.tile_damaged)
	add_child(models.tile_destroyed)
	add_child(models.indicator_solid)
	add_child(models.indicator_dashed)
	add_child(models.indicator_corners)
	if models.get('asset'):
		# translation exists
		if tr(models.asset.name.to_upper()) != models.asset.name.to_upper():
			info = tr(models.asset.name.to_upper())
		
		#models.asset.rotation_degrees.y = randi_range(0, 180)
		models.asset.show()
		add_child(models.asset)
		
		toggle_asset_outline(false)
	
	reset_tile_models()


func reset_tile_models():
	models.tile_highlighted.hide()
	models.tile_targeted.hide()
	models.tile_damaged.hide()
	models.tile_destroyed.hide()
	
	if is_player_clicked:
		models.tile_highlighted.get_active_material(0).albedo_color = Color(TILE_HIGHLIGHTED_COLOR, 0.75)
		models.tile_highlighted.show()
	elif is_player_hovered:
		models.tile_highlighted.get_active_material(0).albedo_color = Color(TILE_HIGHLIGHTED_COLOR, 0.5)
		models.tile_highlighted.show()
	
	if health_type == TileHealthType.DESTROYED:
		models.tile_destroyed.show()
	elif health_type == TileHealthType.DAMAGED:
		models.tile_damaged.show()
	
	if is_planned_enemy_action:
		models.tile_targeted.show()
	
	if is_player_clicked and is_hovered:
		# last (target) tile in path
		#models.indicator_solid.hide()
		models.indicator_dashed.show()
		#models.indicator_corners.hide()
		#position.y = 0.2
		toggle_asset_outline(true)
	elif health_type == TileHealthType.DESTROYED:
		# hardcoded
		position.y = -0.3
	else:
		models.indicator_solid.hide()
		models.indicator_dashed.hide()
		models.indicator_corners.hide()
		#toggle_asset_outline(false)
		#position.y = 0

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


func get_character():
	if player:
		return player
		
	if enemy:
		return enemy
		
	if civilian:
		return civilian
		
	return null


func set_character(character):
	if character.is_in_group('PLAYERS'):
		set_player(character)
	elif character.is_in_group('ENEMIES'):
		set_enemy(character)
	elif character.is_in_group('CIVILIANS'):
		set_civilian(character)
	else:
		printerr('unknown character ' + str(character))


func is_free():
	return health_type != TileHealthType.DESTROYED and health_type != TileHealthType.DESTRUCTIBLE and health_type != TileHealthType.INDESTRUCTIBLE and health_type != TileHealthType.INDESTRUCTIBLE_WALKABLE and not player and not enemy and not civilian


func toggle_shader(is_toggled):
	if is_toggled:
		model_material.set_next_pass(shader_material)
	else:
		model_material.set_next_pass(null)


func toggle_asset_outline(is_outlined):
	if is_instance_valid(models.get('asset_outline')) and not models.asset_outline.is_queued_for_deletion():
		if is_outlined:
			models.asset_outline.show()
		else:
			models.asset_outline.hide()


func toggle_player_hovered(is_toggled):
	is_player_hovered = is_toggled
	
	reset_tile_models()


func toggle_player_clicked(is_toggled):
	is_player_clicked = is_toggled
	
	reset_tile_models()


func set_planned_enemy_action(new_is_planned_enemy_action):
	is_planned_enemy_action = new_is_planned_enemy_action
	
	reset_tile_models()


func apply_action(action_type, action_damage = 0, origin_tile_coords = null):
	match action_type:
		ActionType.NONE: print('no applied action for tile coords ' + str(coords))
		ActionType.CROSS_PUSH_BACK: action_cross_push_back.emit(coords, action_damage, origin_tile_coords)
		_: print('no need for applied action ' + ActionType.keys()[action_type] + ' for tile coords ' + str(coords))


func get_shot(damage, action_type = ActionType.NONE, action_damage = 0, origin_tile_coords = null):
	if player:
		await player.get_shot(damage, action_type, action_damage, origin_tile_coords)
	elif enemy:
		await enemy.get_shot(damage, action_type, action_damage, origin_tile_coords)
	elif civilian:
		await civilian.get_shot(damage, action_type, action_damage, origin_tile_coords)
	else:
		apply_action(action_type, action_damage, origin_tile_coords)
		
		if damage > 0:
			var color_tween = create_tween()
			color_tween.tween_property(model_material, 'albedo_color', model_material.albedo_color, 1.0).from(Color.RED)
			await color_tween.finished
			
			if health_type == TileHealthType.DESTRUCTIBLE:
				health_type = TileHealthType.HEALTHY
				# destroy required asset for destructible tile
				if is_instance_valid(models.get('asset')) and not models.asset.is_queued_for_deletion():
					models.asset.queue_free()
					models.erase('asset')
				
				reset_tile_models()
				print('ttile ' + str(coords) + ' -> healthy tile')
			elif health_type == TileHealthType.HEALTHY:
				health_type = TileHealthType.DAMAGED
				
				reset_tile_models()
				print('ttile ' + str(coords) + ' -> damaged tile')
			elif health_type == TileHealthType.DAMAGED:
				health_type = TileHealthType.DESTROYED
				
				reset_tile_models()
				print('ttile ' + str(coords) + ' -> destroyed')
			elif health_type == TileHealthType.DESTROYED:
				print('ttile ' + str(coords) + ' -> already destroyed, nothing happens')
			elif health_type == TileHealthType.INDESTRUCTIBLE:
				print('ttile ' + str(coords) + ' -> indestructible, nothing happens')
			elif health_type == TileHealthType.INDESTRUCTIBLE_WALKABLE:
				print('ttile ' + str(coords) + ' -> indestructible walkable, nothing happens')
		else:
			print('ttile ' + str(coords) + ' -> got shot with 0 damage')


func on_mouse_entered():
	if models:
		if not is_player_clicked or not is_hovered:
			#models.indicator_solid.hide()
			#models.indicator_dashed.hide()
			models.indicator_corners.show()
	#position.y = 0.15


func _on_area_3d_mouse_entered():
	if is_player_clicked:
		is_hovered = true
		
		reset_tile_models()
		
		#hovered_event.emit(self, true)
	else:
		on_mouse_entered()
		
		if player:
			player.on_mouse_entered()
	
	hovered_event.emit(self, true)


func _on_area_3d_mouse_exited():
	if is_player_clicked:
		is_hovered = false
		
		reset_tile_models()
		
		#hovered_event.emit(self, false)
	else:
		if models:
			models.indicator_corners.hide()
		
		if player:
			player.on_mouse_exited()
	
	hovered_event.emit(self, false)


func _on_area_3d_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked_event.emit(self)
