extends Character

@onready var model = $'target-a-round'

var planned_tile: Node3D


func _ready():
	super()
	
	model_material = StandardMaterial3D.new()


func spawn(target_tile):
	tile = target_tile
	tile.set_enemy(self)
	
	position = Vector3(tile.position.x, 0.0, tile.position.z)


func move(tiles_path, forced):
	if is_alive:
		if not forced and state_type == StateType.SLOW_DOWN:
			print('enemy ' + str(tile.coords) + ' -> slowed down')
			state_type = StateType.NONE
		
		var target_tile = tiles_path.back()
		if target_tile == tile:
			if forced:
				#enemy was pushed/pulled into wall
				await get_shot(1, ActionType.NONE, target_tile.coords)
			else:
				print('enemy ' + str(tile.coords) + ' -> is not moving')
		else:
			if target_tile.player or target_tile.enemy or target_tile.civilian:
				get_shot(1, ActionType.NONE, target_tile.coords)
				await target_tile.get_shot(1, ActionType.NONE, target_tile.coords)
			else:
				tile.set_enemy(null)
				tile = target_tile
				tile.set_enemy(self)
				
				var duration = 0.4 / tiles_path.size()
				for current_tile in tiles_path:
					var position_tween = create_tween()
					position_tween.tween_property(self, 'position', current_tile.position, duration).set_delay(0.1)
					await position_tween.finished


func plan_action(target_tile):
	if is_alive:
		if planned_tile:
			planned_tile.set_planned_enemy_action(false)
			planned_tile = null
		
		planned_tile = target_tile
		planned_tile.set_planned_enemy_action(true)
		
		print('enemy ' + str(tile.coords) + ' -> planned_tile: ' + str(planned_tile.coords))


func execute_planned_action():
	if is_alive:
		if state_type == StateType.MISS_ACTION:
			print('enemy ' + str(tile.coords) + ' -> missed action')
			state_type = StateType.NONE
			return
		
		if planned_tile:
			await planned_tile.get_shot(damage, action_type, tile.coords)
			planned_tile.set_planned_enemy_action(false)
			planned_tile = null


func get_shot(taken_damage, action_type, origin_tile_coords):
	if state_type == StateType.GIVE_SHIELD:
		taken_damage = 0
		print('enemy ' + str(tile.coords) + ' -> was given shield')
		state_type = StateType.NONE
	
	health -= taken_damage
	
	apply_action_type(action_type, origin_tile_coords)
	
	model.set_surface_override_material(0, model_material)
	var color_tween = create_tween()
	color_tween.tween_property(model_material, 'albedo_color', model_material.albedo_color, 1.0).from(Color.RED)
	await color_tween.finished
	model.set_surface_override_material(0, null)
	
	if health <= 0 and is_alive:
		get_killed()


func get_killed():
	is_alive = false
	print('enemy ' + str(tile.coords) + ' -> dead!')
	
	if planned_tile:
		planned_tile.set_planned_enemy_action(false)
		planned_tile = null
	
	tile.set_enemy(null)
	tile = null
	
	model_material.albedo_color = Color.DARK_RED
