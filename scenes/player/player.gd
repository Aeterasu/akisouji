class_name Player extends CharacterBody3D

#TODO: Dustforce/Quake style movement with forces, friction and some sort of boosting

@export_group("Input")
@export var _block_input : bool = false

@export_group("Movement")
@export var velocity_component : VelocityComponent = null
@export var gravity_component : GravityComponent = null
@export var jump_strength : float = 2.0
@export_range(0, 30) var jump_buffer_size : int = 3
@export_range(1.0, 2.0) var sprint_speed_multiplier : float = 1.5
@export var sprint_jumping_boost_amount : float = 1.0
@export var sprint_jumping_falloff : float = 4.0

@export_group("Camera")
@export var camera : PlayerCamera = null
@export var camera_origin : Node3D = null
@export var camera_effect_landing : CameraEffectLanding = null

@export_group("Leaf Cleaning")
@export var cleaning_radius : float = 1.0
@export var jump_cleaning_radius : float = 0.5
@export var sprint_cleaning_cooldown : float = 0.25
@export var sprint_cleaning_radius : float = 0.25

@export_group("Equipment")
@export var inventory : PlayerToolInventory = null
@export var cleaning_range : float = 8.0

var mouse_sensitivity : float = 1.0
var gamepad_sensitvity : float = 64.0
var gamepad_deadzone : float = 0.3

var leaf_cleaning_handler : LeafCleaningHandler = null

var current_jump_buffer_ticks : int = 0

var current_sprint_jump_boost : Vector2 = Vector2()

var sprint_cleaning_timer : Timer = null

var wish_jumping : bool = false
var wish_sprint : bool = false

var is_landing : bool = false

var respawn_transform : Transform3D = Transform3D()

var is_in_photo_mode : bool = false
var default_fov : float = 75.0

func _ready():
	mouse_sensitivity = GlobalSettings.mouse_sensitivity
	gamepad_sensitvity = GlobalSettings.gamepad_sensitvity
	gamepad_deadzone = GlobalSettings.gamepad_deadzone

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

func _physics_process(delta : float):
	input_process(delta)
	movement_process(delta)

	inventory.current_tool.walk_multiplier = velocity_component.current_velocity.length() / velocity_component.speed
	inventory.current_tool._set_sprint_toggle(wish_sprint)

	if (gravity_component.current_velocity < delta - 0.1):
		is_landing = true

	if (is_landing && is_on_floor()):
		is_landing = false
		_on_landing()

func on_broom():
	if (!leaf_cleaning_handler):
		return

	leaf_cleaning_handler._on_player_cleaning_input(cleaning_radius, cleaning_range)

func input_process(delta : float):
	velocity_component.input_direction = Vector2()

	if (_block_input):
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

	if (inventory.current_tool.use_type == PlayerTool.UseType.HOLD):
		inventory.current_tool.in_use = Input.is_action_pressed("player_action_primary") && !wish_sprint
	elif (inventory.current_tool.use_type == PlayerTool.UseType.CLICK):
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
	move_camera(clamp_gamepad_input_by_deadzone(right_stick) * gamepad_sensitvity * delta)

func clamp_gamepad_input_by_deadzone(input : Vector2) -> Vector2:
	if (input.length() < gamepad_deadzone):
		return Vector2.ZERO
	else:
		return input

func _input(event):
	if (_block_input):
		return

	if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE && event is InputEventMouseMotion):
		var mouseMotion = event as InputEventMouseMotion
		move_camera(-mouseMotion.relative * mouse_sensitivity)

	#TODO: move this to main. somehow.
	if event is InputEventMouseButton:
		if (OS.get_name() == "Web"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func move_camera(input : Vector2) -> void:
	rotate_y(deg_to_rad(input.x))
	camera_origin.rotate_x(deg_to_rad(input.y))
	camera_origin.rotation_degrees.x = clampf(camera_origin.rotation_degrees.x, -80.0, 80.0)

func movement_process(delta):
	current_sprint_jump_boost = current_sprint_jump_boost.lerp(Vector2.ZERO, sprint_jumping_falloff * delta)

	if (wish_jumping):
		if (is_on_floor()):
			if (current_jump_buffer_ticks > 0 and wish_sprint):
				current_sprint_jump_boost += velocity_component.current_velocity.normalized() * sprint_jumping_boost_amount		

			gravity_component.hop(jump_strength)
			current_jump_buffer_ticks = 0
			wish_jumping = false
		else:
			current_jump_buffer_ticks += 1

			if (current_jump_buffer_ticks > jump_buffer_size):
				current_jump_buffer_ticks = 0
				wish_jumping = false

	if (wish_sprint):
		velocity_component.speed_multiplier = sprint_speed_multiplier
	else:
		velocity_component.speed_multiplier = 1.0

	velocity = Vector3(velocity_component.current_velocity.x, gravity_component.current_velocity, velocity_component.current_velocity.y) + Vector3(current_sprint_jump_boost.x, 0.0, current_sprint_jump_boost.y)

	move_and_slide()

	if (is_on_floor()):
		gravity_component.current_velocity = -delta	

func is_walking() -> bool:
	return velocity_component.current_velocity.length() > 0.0

func _on_landing():
	var multiplier = 1.0

	if (wish_sprint):
		multiplier = 1.2

	leaf_cleaning_handler._on_player_cleaning_on_position(global_position + Vector3.DOWN, jump_cleaning_radius * multiplier)

	camera_effect_landing._animate()

func _on_sprint_cleaning_timeout():
	if (!wish_sprint or !is_on_floor()):
		return

	leaf_cleaning_handler._on_player_cleaning_on_position(global_position + Vector3.DOWN, sprint_cleaning_radius)

func _on_enter_photo_mode():
	is_in_photo_mode = true
	UI.ui_instance.hide()

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
	UI.ui_instance.show()

	#inventory._get_camera().show()
	CameraUI.instance.hide()
	camera._exit_photo_mode()