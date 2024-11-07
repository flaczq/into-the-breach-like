extends Character

class_name Enemy

signal recalculate_order_event()

const FLASHING_SHADER: Resource = preload('res://Other/flashing_shader.gdshader')

# 1/3 chance of droping loot
var loot_chance: int = 3

var arrow_model_material: StandardMaterial3D
var arrow_shader_material: ShaderMaterial
var planned_tile: Node3D
var order: int
var highlight_tween: Tween
var arrow_color: Color


func _ready():
	super()
	
	#model = $Skeleton_Head
	
	arrow_model_material = StandardMaterial3D.new()
	arrow_model_material.no_depth_test = true
	arrow_model_material.disable_receive_shadows = true
	arrow_model_material.albedo_color = arrow_color
	
	var forced_action_model_material = StandardMaterial3D.new()
	forced_action_model_material.albedo_color = arrow_color
	
	arrow_shader_material = ShaderMaterial.new()
	arrow_shader_material.set_shader(FLASHING_SHADER)
	
	default_arrow_model.get_child(0).set_surface_override_material(0, arrow_model_material)
	default_arrow_sphere_model.set_surface_override_material(0, arrow_model_material)
	default_forced_action_model.set_surface_override_material(0, forced_action_model_material)


func spawn(spawn_tile, new_order):
	tile = spawn_tile
	tile.set_enemy(self)
	
	position = Vector3(tile.position.x, 0.0, tile.position.z)
	
	order = new_order


func move(tiles_path, forced = false, outside_tile_position = null):
	toggle_arrows(false)
	toggle_action_indicators(false)
	
	await super(tiles_path, forced, outside_tile_position)
	
	var target_tile = tiles_path.back()
	if target_tile != tile:
		if not (target_tile.health_type == TileHealthType.DESTRUCTIBLE_HEALTHY or target_tile.health_type == TileHealthType.DESTRUCTIBLE_DAMAGED or target_tile.health_type == TileHealthType.INDESTRUCTIBLE or target_tile.get_character()):
			clear_arrows()
			clear_action_indicators()
			
			tile.set_enemy(null)
			tile = target_tile
			tile.set_enemy(self)
			
			var duration = 0.4 / Global.speed
			for next_tile in tiles_path:
				if not forced:
					look_at_y(next_tile)
				
				var position_tween = create_tween()
				position_tween.tween_property(self, 'position', next_tile.position, duration).set_delay(0.1)
				await position_tween.finished
	
	toggle_arrows(true)
	toggle_action_indicators(true)


func plan_action(target_tile):
	# refresh arrows and indicators
	#if planned_tile != target_tile:
	reset_planned_tile()
	
	if is_alive:
		planned_tile = target_tile
		planned_tile.set_planned_enemy_action(true)
		
		spawn_arrow(planned_tile)
		spawn_action_indicators(planned_tile)
		look_at_y(planned_tile)
		#print('enemy ' + str(tile.coords) + ' -> planned_tile: ' + str(planned_tile.coords))


func execute_planned_action():
	clear_arrows()
	clear_action_indicators()
	
	var temp_planned_tile = null
	if planned_tile:
		# remember planned tile to be able to unset it before shooting
		temp_planned_tile = planned_tile
		planned_tile.set_planned_enemy_action(false)
		planned_tile = null
	
	if is_alive:
		if state_type == StateType.MISS_ACTION:
			print('enemy ' + str(tile.coords) + ' -> missed action')
			state_type = StateType.NONE
			return
		
		if temp_planned_tile:
			await spawn_bullet(temp_planned_tile)
			await temp_planned_tile.get_shot(damage, action_type, action_damage, tile.coords)


func get_killed():
	super()
	print('enemy ' + str(tile.coords) + ' -> dead!')
	
	reset_planned_tile()
	
	tile.set_enemy(null)
	tile = null
	
	recalculate_order_event.emit()
	
	# maybe spawn loot
	if (randi() % loot_chance) == (loot_chance - 1):
		var loot_model = default_loot_model.duplicate()
		loot_model.position = position
		loot_model.show()
		add_child(loot_model)


func reset_planned_tile():
	clear_arrows()
	clear_action_indicators()
	
	if planned_tile:
		planned_tile.set_planned_enemy_action(false)
		planned_tile = null


func toggle_health_bar(is_toggled, displayed_health = health):
	super(is_toggled, displayed_health)
	
	if health_bar:
		if is_toggled:
			var top_model_position = Vector3(model.global_position.x, model.global_position.y, model.global_position.z)
			health_bar.position = get_viewport().get_camera_3d().unproject_position(model.global_transform.origin)
			health_bar.position.x -= 33
			
			# hardcoded
			if is_close(get_viewport().get_camera_3d().rotation_degrees.x, -50):
				health_bar.position.y -= 41
			elif is_close(get_viewport().get_camera_3d().rotation_degrees.x, -40):
				health_bar.position.y -= 43
			else:
				health_bar.position.y -= 44


func toggle_arrow_highlight(is_toggled):
	# MAYBE show arrows only when hovered
	#for child in get_children().filter(func(child): return child.is_in_group('ARROW') and child.name != 'ArrowSignContainer'):
		#if is_toggled:
			#child.show()
		#else:
			#child.hide()
	
	if highlight_tween:
		highlight_tween.kill()
	
	if is_toggled:
		highlight_tween = create_tween().set_loops()
		highlight_tween.tween_property(arrow_model_material, 'albedo_color', ENEMY_ARROW_HIGHLIGHTED_COLOR, 0.3)
		highlight_tween.tween_property(arrow_model_material, 'albedo_color', arrow_color, 0.3).set_delay(0.5)
		#arrow_model_material.albedo_color = Color.YELLOW
		#arrow_model_material.set_next_pass(arrow_shader_material)
	else:
		arrow_model_material.albedo_color = arrow_color
		#arrow_model_material.set_next_pass(null)
