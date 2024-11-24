class_name Player extends CharacterBody3D

#TODO: Dustforce/Quake style movement with forces, friction and some sort of boosting

const CAMERA_ROTATION_LIMIT : float = 80.0

@export_group("Input")
@export var _block_input : bool = false

@export_group("Movement")
@export var velocity_component : VelocityComponent = null
@export var gravity : float = 9.8
@export var jump_strength : float = 2.0
@export_range(0, 30) var jump_buffer_size : int = 3
@export_range(1.0, 2.0) var sprint_speed_multiplier : float = 1.5
@export var sprint_jumping_boost_amount : float = 1.0
@export var sprint_jumping_falloff : float = 4.0
@export_range(0.0, 90.0) var look_down_slowdown_threshold : float = 30.0
@export_range(0.1, 1.0) var look_down_slowdown_coeff : float = 0.2

@export_group("Camera")
@export var camera : PlayerCamera = null
@export var camera_origin : Node3D = null
@export var camera_effect_landing : CameraEffectLanding = null

@export_group("Leaf Cleaning")
@export var cleaning_raycast : RayCast3D = null
@export var jump_cleaning_radius : float = 0.5
@export var sprint_cleaning_cooldown : float = 0.25
@export var sprint_cleaning_radius : float = 0.25

@export_group("Equipment")
@export var inventory : PlayerToolInventory = null
@export var move_speed_upgrade_handler : MoveSpeedUpgradeHandler = null

@export_group("Audio")
@export var audio_jump : SoundEffectPlayer = null
@export var audio_land : SoundEffectPlayer = null
@export var footstep_manager : FootstepManager = null

@export_group("Fx")
@export var landing_particles : GPUParticles3D = null
@export var running_particles : GPUParticles3D = null

var leaf_cleaning_handler : LeafCleaningHandler = null
var broom_data : BroomData = null
var brooming_tick_cooldown : int = 0

var current_jump_buffer_ticks : int = 0

var current_sprint_jump_boost : Vector2 = Vector2()

var sprint_cleaning_timer : Timer = null

var wish_jumping : bool = false
var wish_sprint : bool = false

var is_landing : bool = false

var wish_cleaning_toggle : bool = false

var respawn_transform : Transform3D = Transform3D()

var input_delay : float = 0.0
var block_brooming_until_key_is_released : bool = false

var is_in_photo_mode : bool = false
var default_fov : float = 75.0

func _ready():
	#equipment_viewmodel.on_broom.connect(on_broom)

	sprint_cleaning_timer = Timer.new()
	add_child(sprint_cleaning_timer)
	sprint_cleaning_timer.wait_time = sprint_cleaning_cooldown
	sprint_cleaning_timer.timeout.connect(_on_sprint_cleaning_timeout)
	sprint_cleaning_timer.start()

	inventory._set_tool(0)

	for player_tool in inventory.tools:
		if (player_tool is Broom):
			player_tool.on_broom.connect(on_broom)

	var camera_tool = inventory._get_camera()
	camera_tool.on_enter_photo_mode.connect(_on_enter_photo_mode)
	camera_tool.on_exit_photo_mode.connect(_on_exit_photo_mode)

	footstep_manager.on_footstep.connect(_on_footstep)

	# upgrade handling

	UpgradeManager.on_boots_update.connect(_on_boots_upgrade_update)
	UpgradeManager.on_broom_update.connect(_on_broom_upgrade_update)
	_on_boots_upgrade_update()

	for node in UpgradeManager.inventory:
		if (node is BroomUpgrade):
			UpgradeManager.on_broom_update.emit(node as BroomUpgrade)
	#_on_broom_upgrade_update()

func _physics_process(delta : float):
	input_process(delta)
	movement_process(delta)

	if (inventory.current_tool is Broom):
		broom_data = (inventory.current_tool as Broom).data
		cleaning_raycast.target_position = Vector3(0, 0, -1) * broom_data.cleaning_range

	inventory.current_tool.walk_multiplier = velocity_component.current_velocity.length() / velocity_component.speed

	inventory.current_tool._set_sprint_toggle(wish_sprint)

	if (velocity.y < delta - 0.1):
		is_landing = true

	if (is_landing && is_on_floor()):
		is_landing = false
		_on_landing()

	input_delay = max(input_delay - delta, 0.0)

	if (inventory.current_tool.in_use):
		brooming_tick_cooldown -= 1

		if (brooming_tick_cooldown < 0):
			brooming_tick_cooldown = broom_data.brooming_tickrate
			on_broom()

func _get_cleaning_raycast() -> Object:
	var screen_size = get_viewport().size
	var screen_center = Vector2(screen_size.x * 0.5, screen_size.y * 0.5)

	cleaning_raycast.force_raycast_update()

	return cleaning_raycast.get_collider()

func on_broom():
	if (!leaf_cleaning_handler):
		return

	if (_get_cleaning_raycast()):
		var cleaning_point = cleaning_raycast.get_collision_point()
		var golden_multiplier : float = 1.0

		if (broom_data.use_golden_broom_multiplier):
			golden_multiplier = CashManager._get_golden_broom_multiplier()

		Game.game_instance.last_cleaning_position = cleaning_point
		Game.game_instance.last_cleaning_radius = broom_data.cleaning_area.length() * golden_multiplier
		leaf_cleaning_handler.RequestCleaningAtPosition(Vector2(cleaning_point.x, cleaning_point.z), Vector2(sin(rotation.y), cos(rotation.y)), broom_data.cleaning_area * golden_multiplier)

	pass

func on_leafblower_supercharge(leafblower : LeafBlower):
	if (!leaf_cleaning_handler):
		return

	if (_get_cleaning_raycast()):
		var cleaning_point = cleaning_raycast.get_collision_point()
		Game.game_instance.last_cleaning_position = cleaning_point
		Game.game_instance.last_cleaning_radius = leafblower.supercharge_data.cleaning_area.length()
		leaf_cleaning_handler.RequestCleaningAtPosition(Vector2(cleaning_point.x, cleaning_point.z), Vector2(sin(rotation.y), cos(rotation.y)), leafblower.supercharge_data.cleaning_area)

	pass

func input_process(delta : float):
	velocity_component.input_direction = Vector2()

	if (Input.is_action_just_released("player_action_primary")):
		block_brooming_until_key_is_released = false

	if (_block_input or input_delay > 0.0):
		#equipment_viewmodel.wish_brooming = false
		wish_sprint = false
		wish_jumping = false
		return

	match InputDeviceCheck.input_device:
		InputDeviceCheck.InputDevice.KEYBOARD_MOUSE:
			velocity_component.input_direction = get_input_direction().normalized()
		InputDeviceCheck.InputDevice.GAMEPAD:
			velocity_component.input_direction = get_input_direction()
			move_camera_gamepad(delta)

	velocity_component.input_direction = velocity_component.input_direction.rotated(-rotation.y)

	if (velocity_component.input_direction.length() < 0.5):
		wish_sprint = false

	# jump

	if (Input.is_action_just_pressed("player_action_jump")):
		wish_jumping = true

	# broom

	if (!block_brooming_until_key_is_released):
		if (inventory.current_tool.use_type == PlayerTool.UseType.HOLD):
			if (!GlobalSettings.toggle_to_clean):
				inventory.current_tool.in_use = (Input.is_action_pressed("player_action_primary") or inventory.current_tool.auto_use) && !wish_sprint
			else:
				if (Input.is_action_just_pressed("player_action_primary")):
					wish_cleaning_toggle = not wish_cleaning_toggle

				inventory.current_tool.in_use = (wish_cleaning_toggle or inventory.current_tool.auto_use) && !wish_sprint

			#if (inventory.current_tool is LeafBlower):
				#var leafblower = inventory.current_tool as LeafBlower
				#leafblower.wish_charge = Input.is_action_pressed("player_action_secondary") && !wish_sprint

				#if (leafblower.wish_charge and leafblower.current_charge >= leafblower.charge_duration):
					#leafblower._release_charge()
					#on_leafblower_supercharge(leafblower)

		elif (inventory.current_tool.use_type == PlayerTool.UseType.CLICK):
			wish_cleaning_toggle = false

			if (Input.is_action_just_pressed("player_action_primary") && !wish_sprint):
				inventory.current_tool._use_primary()
			if (Input.is_action_just_pressed("player_action_secondary") && !wish_sprint):
				inventory.current_tool._use_secondary()

	# sprint

	if (Input.is_action_just_pressed("player_action_sprint") && velocity_component.input_direction.length() > 0.0 && is_on_floor()):
		wish_sprint = !wish_sprint

func get_input_direction() -> Vector2:
	var result = Vector2()

	result = Input.get_vector("player_move_left", "player_move_right", "player_move_forward", "player_move_backwards")

	return result

func move_camera_gamepad(delta : float):
	var right_stick = CameraControls._get_gamepad_camera_input_vector()
	move_camera(clamp_gamepad_input_by_deadzone(right_stick) * GlobalSettings.gamepad_sensitvity * delta)

func clamp_gamepad_input_by_deadzone(input : Vector2) -> Vector2:
	if (input.length() < GlobalSettings.gamepad_deadzone):
		return Vector2.ZERO
	else:
		return input

func _input(event):
	if (_block_input):
		return

	if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE && event is InputEventMouseMotion):
		var mouseMotion = event as InputEventMouseMotion
		move_camera(-mouseMotion.relative * GlobalSettings.mouse_sensitivity)

func move_camera(input : Vector2) -> void:
	rotate_y(deg_to_rad(input.x))
	camera_origin.rotate_x(deg_to_rad(input.y))
	camera_origin.rotation_degrees.x = clampf(camera_origin.rotation_degrees.x, -CAMERA_ROTATION_LIMIT, CAMERA_ROTATION_LIMIT)

func movement_process(delta):
	current_sprint_jump_boost = current_sprint_jump_boost.lerp(Vector2.ZERO, sprint_jumping_falloff * delta)

	velocity.y -= gravity * delta

	if (is_on_floor()):
		velocity.y = 0

	if (wish_jumping):
		if (is_on_floor()):
			if (current_jump_buffer_ticks > 0 and wish_sprint):
				current_sprint_jump_boost += velocity_component.current_velocity.normalized() * sprint_jumping_boost_amount		

			velocity.y = jump_strength
			current_jump_buffer_ticks = 0
			wish_jumping = false

			audio_jump.play()
		else:
			current_jump_buffer_ticks += 1

			if (current_jump_buffer_ticks > jump_buffer_size):
				current_jump_buffer_ticks = 0
				wish_jumping = false

	if (wish_sprint):
		velocity_component.speed_multiplier = sprint_speed_multiplier
	else:
		velocity_component.speed_multiplier = 1.0
		# camera rotation slowdown
		var coeff : float = clamp((clamp(abs(clamp(camera_origin.rotation_degrees.x, -CAMERA_ROTATION_LIMIT, 0.0)), look_down_slowdown_threshold, CAMERA_ROTATION_LIMIT) - look_down_slowdown_threshold) / (CAMERA_ROTATION_LIMIT - look_down_slowdown_threshold), look_down_slowdown_coeff, 1.0)
		velocity_component.speed_multiplier *= 1.0 + look_down_slowdown_coeff - coeff

	# apply movement

	velocity = Vector3(velocity_component.current_velocity.x, velocity.y, velocity_component.current_velocity.y) + Vector3(current_sprint_jump_boost.x, 0.0, current_sprint_jump_boost.y)

	move_and_slide()

func is_walking() -> bool:
	return velocity_component.current_velocity.length() > 0.0

func _on_landing():
	var multiplier = 1.0

	if (wish_sprint):
		multiplier = 1.2

	if (is_instance_valid(leaf_cleaning_handler)):
		Game.game_instance.last_cleaning_position = global_position + Vector3.DOWN * 0.5
		Game.game_instance.last_cleaning_radius = jump_cleaning_radius * multiplier
		leaf_cleaning_handler.RequestCleaningAtPosition(Vector2(global_position.x, global_position.z), Vector2(cos(rotation.y), sin(rotation.y)), Vector2.ONE * jump_cleaning_radius * multiplier * move_speed_upgrade_handler.current_upgrade.jump_cleaning_range_multiplier)

	camera_effect_landing._animate()

	footstep_manager.cur_step_rate = 0.0
	audio_land.play()

	var particles = landing_particles.duplicate()
	add_child(particles)
	particles.set_deferred("emitting", true)
	particles.finished.connect(particles.queue_free)

func _on_sprint_cleaning_timeout():
	if (!is_on_floor()):
		return

	if (!wish_sprint and !move_speed_upgrade_handler.current_upgrade.allow_walk_cleaning):
		return

	var range_multiplier : float = 1.0

	if (wish_sprint):
		range_multiplier = move_speed_upgrade_handler.current_upgrade.sprint_cleaning_range_multiplier
	else:
		range_multiplier = move_speed_upgrade_handler.current_upgrade.walk_cleaning_range_multiplier
	
	if (is_instance_valid(leaf_cleaning_handler)):
		Game.game_instance.last_cleaning_position = global_position + Vector3.DOWN * 0.5
		Game.game_instance.last_cleaning_radius = sprint_cleaning_radius
		leaf_cleaning_handler.RequestCleaningAtPosition(Vector2(global_position.x, global_position.z), Vector2(cos(rotation.y), sin(rotation.y)), Vector2.ONE * sprint_cleaning_radius * range_multiplier)

func _on_enter_photo_mode():
	is_in_photo_mode = true
	UI.instance.hide()

	#inventory._get_camera().hide()
	CameraUI.instance.show()
	camera._enter_photo_mode()
	
	var tween = create_tween()
	tween.tween_property(BlackoutLayer.instance.black_rect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	tween.tween_property(BlackoutLayer.instance.black_rect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.1).set_delay(0.1)

func _on_exit_photo_mode():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(BlackoutLayer.instance.black_rect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	tween.tween_property(BlackoutLayer.instance.black_rect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.1).set_delay(0.1)
	tween.tween_callback(_photo_mode_exit_callback).set_delay(0.1)
	
func _photo_mode_exit_callback() -> void:
	is_in_photo_mode = false
	UI.instance.show()

	#inventory._get_camera().show()
	CameraUI.instance.hide()
	camera._exit_photo_mode()

func _on_boots_upgrade_update():
	move_speed_upgrade_handler.current_upgrade = UpgradeManager.current_boots

func _on_broom_upgrade_update(broom : BroomUpgrade):
	if (!broom.broom_scene):
		return

	var node = broom.broom_scene.instantiate()
	inventory.tool_origin.add_child(node)

	inventory.tools.insert(len(inventory.tools) - 1, node)
	inventory.current_tool_id = len(inventory.tools) - 2
	inventory.swap_cooldown_timer.stop()
	inventory._update_tool()

	if (node is Broom):
		var b = node as Broom
		b.on_sweep_fx.connect(_on_sweep_fx)

func _on_footstep():
	if (!wish_sprint):
		return

	var particles = running_particles.duplicate()
	add_child(particles)
	particles.set_deferred("emitting", true)
	particles.finished.connect(particles.queue_free)

func _on_sweep_fx(broom : Broom) -> void:
	if (_get_cleaning_raycast()):
		var cleaning_point = cleaning_raycast.get_collision_point()
		var particles = running_particles.duplicate()
		add_child(particles)
		(particles as Node3D).global_position = cleaning_point
		particles.set_deferred("emitting", true)
		particles.finished.connect(particles.queue_free)

		broom.sweep_audio.play()

		#Game.game_instance.audio_handler._on_leaves_cleaned(1)