extends Character

class_name Enemy

signal planned_action_miss_move(target_character: Character, is_applied: bool)
signal planned_action_miss_action(target_character: Character, is_applied: bool)
signal killed_event(target_enemy: Enemy)

@onready var animation_player = $Area3D/AnimationPlayer

const FLASHING_SHADER: Resource = preload('res://Other/flashing_shader.gdshader')

# 1/10 chance of droping bonus
var bonus_chance: int = 10

var id: EnemyType
var arrow_model_material: StandardMaterial3D
var arrow_shader_material: ShaderMaterial
var planned_tile: MapTile
var order: int
var highlight_tween: Tween
var arrow_color: Color
var arrow_highlighted_color: Color


func _ready() -> void:
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
	
	#animation_player.play('idle')


func after_ready() -> void:
	super()


func spawn(spawn_tile: MapTile, new_order: int) -> void:
	tile = spawn_tile
	tile.set_enemy(self)
	
	position = Vector3(tile.position.x, 0.0, tile.position.z)
	order = new_order


func move(tiles_path: Array[MapTile], forced: bool = false, outside_tile_position: Vector3 = Vector3.ZERO) -> void:
	if not forced and state_types.has(StateType.MISSED_MOVE):
		print('evemy ' + str(tile.coords) + ' -> missed move')
		state_types.erase(StateType.MISSED_MOVE)
		return
	
	# cannot move to INDESTRUCTIBLE_WALKABLE so any move resets this state
	if not forced and state_types.has(StateType.SLOWED_DOWN):
		print('evemy ' + str(tile.coords) + ' -> slowed down')
		state_types.erase(StateType.SLOWED_DOWN)
	
	animation_player.stop()
	toggle_arrows(false)
	#toggle_action_indicators(false)
	
	# can get killed here
	await super(tiles_path, forced, outside_tile_position)
	
	if not is_alive:
		return
	
	var target_tile = tiles_path.back() as MapTile
	if target_tile != tile:
		if not target_tile.is_occupied():
			clear_arrows()
			clear_action_indicators()
			
			tile.set_enemy(null)
			tile = target_tile
			tile.set_enemy(self)
			
			var duration = Global.character_speed / Global.game_speed
			for next_tile in tiles_path:
				if not forced:
					look_at_y(next_tile)
				
				var position_tween = create_tween()
				position_tween.tween_property(self, 'position', next_tile.position, duration).set_delay(0.0)
				await position_tween.finished
			
			collect_if_collectable(target_tile)
	
	toggle_arrows(true)
	animation_player.play('idle')
	#toggle_action_indicators(true)


func plan_action(target_tile: MapTile) -> void:
	var different_tile: bool = (planned_tile != target_tile)
	# refresh arrows and indicators
	reset_planned_tile(different_tile)
	
	if is_alive:
		planned_tile = target_tile
		planned_tile.set_planned_enemy_action(true)
		
		if different_tile:
			var target_character = planned_tile.get_character()
			if target_character:
				apply_planned_action(target_character)
		
		spawn_arrow(planned_tile)
		spawn_action_indicators(planned_tile, tile, tile.position, action_1.id)
		toggle_action_indicators(false)
		look_at_y(planned_tile)
		#print('enemy ' + str(tile.coords) + ' -> planned_tile: ' + str(planned_tile.coords))


func execute_planned_action() -> void:
	animation_player.stop()
	clear_arrows()
	clear_action_indicators()
	
	var temp_planned_tile = null
	if planned_tile:
		var target_character = planned_tile.get_character()
		if target_character:
			apply_planned_action(target_character, false)
		
		# remember planned tile to be able to unset it before actions
		temp_planned_tile = planned_tile
		planned_tile.set_planned_enemy_action(false)
		planned_tile = null
	
	if is_alive:
		if state_types.has(StateType.MISSED_ACTION):
			print('enemy ' + str(tile.coords) + ' -> missed action')
			animation_player.play('idle')
			state_types.erase(StateType.MISSED_ACTION)
			return
		
		if temp_planned_tile:
			if action_1.id != ActionType.TOWARDS_AND_PUSH_BACK:
				await spawn_bullet(temp_planned_tile)
			await temp_planned_tile.get_shot(damage, action_1.id, action_1.damage, tile.coords)
			
			animation_player.play('idle')


func apply_planned_action(target_character: Character, is_applied = true) -> void:
	match action_1.id:
		ActionType.MISS_MOVE: planned_action_miss_move.emit(target_character, is_applied)
		ActionType.MISS_ACTION: planned_action_miss_action.emit(target_character, is_applied)
		_: pass#print('no implementation of applied planned action: ' + ActionType.keys()[action_1.id] + ' for character: ' + str(self))


func get_killed() -> void:
	super()
	print('enemy ' + str(tile.coords) + ' -> dead!')
	
	spawn_bonus()
	
	reset_planned_tile()
	
	tile.set_enemy(null)
	tile = null
	
	killed_event.emit(self)


func spawn_bonus() -> void:
	if tile.is_free() and (randi() % bonus_chance) == (bonus_chance - 1):
		var bonus_model = default_bonus_model.duplicate()
		bonus_model.position = Vector3(0, 0.2, 0)
		bonus_model.show()
		tile.add_child(bonus_model)


func reset_planned_tile(reset_planned_action: bool = true) -> void:
	clear_arrows()
	clear_action_indicators()
	
	if planned_tile:
		if reset_planned_action:
			var target_character = planned_tile.get_character()
			if target_character:
				apply_planned_action(target_character, false)
		
		planned_tile.set_planned_enemy_action(false)
		planned_tile = null


func toggle_health_bar(is_toggled: bool, displayed_health: int = health) -> void:
	super(is_toggled, displayed_health)
	
	if health_bar:
		if is_toggled:
			var top_model_position = Vector3(model.global_position.x, model.global_position.y, model.global_position.z)
			health_bar.position = get_viewport().get_camera_3d().unproject_position(model.global_transform.origin)
			health_bar.position.x -= 30
			
			# hardcoded
			if Global.camera_position == CameraPosition.HIGH:
				health_bar.position.y -= 41
			elif Global.camera_position == CameraPosition.MIDDLE:
				health_bar.position.y -= 45
			elif Global.camera_position == CameraPosition.LOW:
				health_bar.position.y -= 49


func toggle_arrow_highlight(is_toggled: bool) -> void:
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
		highlight_tween.tween_property(arrow_model_material, 'albedo_color', arrow_highlighted_color, 0.3)
		highlight_tween.tween_property(arrow_model_material, 'albedo_color', arrow_color, 0.3).set_delay(0.5)
		#arrow_model_material.albedo_color = Color.YELLOW
		#arrow_model_material.set_next_pass(arrow_shader_material)
	else:
		arrow_model_material.albedo_color = arrow_color
		#arrow_model_material.set_next_pass(null)
