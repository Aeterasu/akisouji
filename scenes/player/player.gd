class_name Player extends CharacterBody3D

#TODO: Dustforce/Quake style movement with forces, friction and some sort of boosting

@export_group("Movement")
@export var velocity_component : VelocityComponent = null
@export var gravity_component : GravityComponent = null

@export_group("Camera")
@export var camera : Camera3D = null
@export var camera_origin : Node3D = null

@export_group("Leaf Cleaning")
@export var cleaning_radius : int = 1
@export var leaf_cleaning_handler : LeafCleaningHandler = null

var mouse_sensitivity : float = 1.0
var gamepad_sensitvity : float = 64.0
var gamepad_deadzone : float = 0.3

func _ready():
	mouse_sensitivity = GlobalSettings.mouse_sensitivity
	gamepad_sensitvity = GlobalSettings.gamepad_sensitvity
	gamepad_deadzone = GlobalSettings.gamepad_deadzone

func _physics_process(delta : float):
	input_process(delta)
	movement_process(delta)

	if (Input.is_action_just_pressed("player_action_primary")):
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

func move_camera(input : Vector2) -> void:
	rotate_y(deg_to_rad(input.x))
	camera_origin.rotate_x(deg_to_rad(input.y))
	camera_origin.rotation_degrees.x = clampf(camera_origin.rotation_degrees.x, -80.0, 80.0)

func movement_process(delta):
	velocity = Vector3(velocity_component.current_velocity.x, gravity_component.current_velocity, velocity_component.current_velocity.y)

	move_and_slide()

	if (is_on_floor()):
		gravity_component.current_velocity = -delta	

func is_walking() -> bool:
	return velocity_component.current_velocity.length() > 0.0
