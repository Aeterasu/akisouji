extends Node

enum InputDevice { KEYBOARD_MOUSE, GAMEPAD, }

var input_device : InputDevice = InputDevice.KEYBOARD_MOUSE

var joy_name : String = ""

func _input(event):
	if (event is InputEventKey || event is InputEventMouseButton):
		input_device = InputDevice.KEYBOARD_MOUSE
		joy_name = ""
	elif (event is InputEventJoypadButton):
		input_device = InputDevice.GAMEPAD
		joy_name = Input.get_joy_name(0)
	elif (event is InputEventJoypadMotion && abs((event as InputEventJoypadMotion).axis_value) >= 0.95):
		input_device = InputDevice.GAMEPAD
		joy_name = Input.get_joy_name(0)		