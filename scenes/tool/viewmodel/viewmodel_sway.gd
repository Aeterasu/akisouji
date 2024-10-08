extends Node3D

@export var sway_strength : float = 1.0
@export var decay_weight : float = 3.0

var current_sway : Vector2 = Vector2()

func _physics_process(delta):
	current_sway += CameraControls._get_gamepad_camera_input_vector() / 2
	current_sway = current_sway.lerp(Vector2.ZERO, decay_weight * delta)
	rotation_degrees = Vector3(current_sway.y, current_sway.x, 0.0)

func _input(event):
	if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE && event is InputEventMouseMotion):
		var mouseMotion = event as InputEventMouseMotion
		current_sway += -mouseMotion.relative * GlobalSettings.mouse_sensitivity * sway_strength