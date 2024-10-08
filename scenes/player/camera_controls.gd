class_name CameraControls

static func _get_gamepad_camera_input_vector() -> Vector2:
    return -Input.get_vector("right_stick_left", "right_stick_right", "right_stick_up", "right_stick_down")