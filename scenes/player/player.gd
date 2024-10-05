class_name Player extends CharacterBody3D

#TODO: Dustforce/Quake style movement with forces, friction and some sort of boosting

@export_group("Movement")
@export var velocity_component : VelocityComponent = null
@export var gravity_component : GravityComponent = null
@export var jump_strength : float = 2.0
@export_range(0, 30) var jump_buffer_size : int = 3
@export_range(1.0, 2.0) var sprint_speed_multiplier : float = 1.5

@export_group("Camera")
@export var camera : Camera3D = null
@export var camera_origin : Node3D = null

@export_group("Leaf Cleaning")
@export var cleaning_radius : float = 1.0
@export var leaf_cleaning_handler : LeafCleaningHandler = null

@export_group("Equipment")
@export var equipment_viewmodel : BroomViewmodel = null

var mouse_sensitivity : float = 1.0
var gamepad_sensitvity : float = 64.0
var gamepad_deadzone : float = 0.3

var current_jump_buffer_ticks : int = 0

var wish_jumping : bool = false
var wish_sprint : bool = false

func _ready():
	mouse_sensitivity = GlobalSettings.mouse_sensitivity
	gamepad_sensitvity = GlobalSettings.gamepad_sensitvity
	gamepad_deadzone = GlobalSettings.gamepad_deadzone

	equipment_viewmodel.on_broom.connect(on_broom)

func _physics_process(delta : float):
	input_process(delta)
	movement_process(delta)

	equipment_viewmodel.walk_multiplier = velocity_component.current_velocity.length() / velocity_component.speed

func on_broom():
	leaf_cleaning_handler._on_player_cleaning_input(cleaning_radius)

func input_process(delta : float):
	velocity_component.input_direction = Vector2()

	match InputDeviceCheck.input_device:
		InputDeviceCheck.InputDevice.KEYBOARD_MOUSE:
			velocity_component.input_direction = get_input_direction().normalized()
		InputDeviceCheck.InputDevice.GAMEPAD:
			velocity_component.input_direction = get_input_direction()
			move_camera_gamepad(delta)

	velocity_component.input_direction = velocity_component.input_direction.rotated(-rotation.y)

	if (velocity_component.input_direction.length() < 0.5):
		toggle_sprint(false)

	# jump

	if (Input.is_action_just_pressed("player_action_jump")):
		wish_jumping = true
		#gravity_component.hop(jump_strength)

	# broom

	if (Input.is_action_pressed("player_action_primary")):
		equipment_viewmodel._attempt_brooming()

	# sprint

	if (Input.is_action_just_pressed("player_action_sprint") && velocity_component.input_direction.length() > 0.0 && is_on_floor()):
		toggle_sprint(!wish_sprint)

func get_input_direction() -> Vector2:
	var result = Vector2()

	result = Input.get_vector("player_move_left", "player_move_right", "player_move_forward", "player_move_backwards")

	return result

func move_camera_gamepad(delta : float):
	var right_stick = -Input.get_vector("right_stick_left", "right_stick_right", "right_stick_up", "right_stick_down")
	move_camera(clamp_gamepad_input_by_deadzone(right_stick) * gamepad_sensitvity * delta)

func clamp_gamepad_input_by_deadzone(input : Vector2) -> Vector2:
	if (input.length() < gamepad_deadzone):
		return Vector2.ZERO
	else:
		return input

func _input(event):
	if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE && event is InputEventMouseMotion):
		var mouseMotion = event as InputEventMouseMotion
		move_camera(-mouseMotion.relative * mouse_sensitivity)

	if event is InputEventMouseButton:
		if (OS.get_name() == "Web"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func move_camera(input : Vector2) -> void:
	rotate_y(deg_to_rad(input.x))
	camera_origin.rotate_x(deg_to_rad(input.y))
	camera_origin.rotation_degrees.x = clampf(camera_origin.rotation_degrees.x, -80.0, 80.0)

func movement_process(delta):
	if (wish_jumping):
		if (is_on_floor()):
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

	velocity = Vector3(velocity_component.current_velocity.x, gravity_component.current_velocity, velocity_component.current_velocity.y)

	move_and_slide()

	if (is_on_floor()):
		gravity_component.current_velocity = -delta	

func is_walking() -> bool:
	return velocity_component.current_velocity.length() > 0.0

func toggle_sprint(toggle : bool):
	if (wish_sprint != toggle):
		if (toggle):
			equipment_viewmodel._animate_sprint_init()
		else:
			equipment_viewmodel._animate_sprint_end()

	wish_sprint = toggle	