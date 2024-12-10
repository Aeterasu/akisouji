extends Node

@export var glyph_image : Texture2D = null

func _get_glyph_image_path() -> String:
	return glyph_image.resource_path

func _get_key_string(input : InputEvent) -> String:
	if (input is InputEventKey):
		return OS.get_keycode_string((input as InputEventKey).physical_keycode)

	return ""

func _get_glyph_bbcode(input : InputEvent) -> String:
	var result : String = ""

	if (input is InputEventKey):
		result = "[" + OS.get_keycode_string((input as InputEventKey).physical_keycode) + "]"
	elif (input is InputEventMouseButton):
		match (input as InputEventMouseButton).button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
				result = "[img region=32,128,32,32]" + _get_glyph_image_path() + "[/img]"
			MouseButton.MOUSE_BUTTON_RIGHT:
				result = "[img region=64,128,32,32]" + _get_glyph_image_path() + "[/img]"
			MouseButton.MOUSE_BUTTON_MIDDLE:
				result = "[img region=96,128,32,32]" + _get_glyph_image_path() + "[/img]"
			MouseButton.MOUSE_BUTTON_WHEEL_UP:
				result = "[img region=160,128,32,32]" + _get_glyph_image_path() + "[/img]"
			MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
				result = "[img region=192,128,32,32]" + _get_glyph_image_path() + "[/img]"
	elif (input is InputEventJoypadMotion):
		var joypadMotion = input as InputEventJoypadMotion;
		var joypadName = Input.get_joy_name(0);

		match joypadName:
			"XInput Gamepad":
				result = _get_xbox_axis(joypadMotion.axis)
			"PS4 Controller":
				result = _get_playstation_axis(joypadMotion.axis)
			"PS5 Controller":
				result = _get_playstation_axis(joypadMotion.axis)
			_:
				result = _get_xbox_axis(joypadMotion.axis)
	elif (input is InputEventJoypadButton):
		var joypadButton = input as InputEventJoypadButton;
		var joypadName = Input.get_joy_name(0);

		match joypadName:
			"XInput Gamepad":
				result = _get_xbox_button(joypadButton.button_index)
			"PS4 Controller":
				result = _get_playstation_button(joypadButton.button_index)
			"PS5 Controller":
				result = _get_playstation_button(joypadButton.button_index)
			_:
				result = _get_xbox_button(joypadButton.button_index)

	if (result == ""):
		return input.as_text()

	return result

func _get_xbox_axis(axis : JoyAxis) -> String:
	match axis:
		JoyAxis.JOY_AXIS_LEFT_X:
			return "[img region=0,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyAxis.JOY_AXIS_LEFT_Y:
			return "[img region=0,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyAxis.JOY_AXIS_RIGHT_X:
			return "[img region=32,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyAxis.JOY_AXIS_RIGHT_Y:
			return "[img region=32,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyAxis.JOY_AXIS_TRIGGER_LEFT:
			return "[img region=192,0,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyAxis.JOY_AXIS_TRIGGER_RIGHT:
			return "[img region=224,0,32,32]" + _get_glyph_image_path() + "[/img]"
	
	return ""

func _get_playstation_axis(axis : JoyAxis) -> String:
	match axis:
		JoyAxis.JOY_AXIS_LEFT_X:
			return "[img region=0,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyAxis.JOY_AXIS_LEFT_Y:
			return "[img region=0,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyAxis.JOY_AXIS_RIGHT_X:
			return "[img region=32,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyAxis.JOY_AXIS_RIGHT_Y:
			return "[img region=32,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyAxis.JOY_AXIS_TRIGGER_LEFT:
			return "[img region=192,96,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyAxis.JOY_AXIS_TRIGGER_RIGHT:
			return "[img region=224,96,32,32]" + _get_glyph_image_path() + "[/img]"
	
	return ""

func _get_xbox_button(button : JoyButton) -> String:
	match button:
		JoyButton.JOY_BUTTON_A:
			return "[img region=0,0,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_B:
			return "[img region=32,0,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_X:
			return "[img region=64,0,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_Y:
			return "[img region=96,0,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_BACK:
			return "[img region=160,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_GUIDE:
			return "[img region=128,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_START:
			return "[img region=128,064,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_LEFT_STICK:
			return "[img region=64,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_RIGHT_STICK:
			return "[img region=96,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_LEFT_SHOULDER:
			return "[img region=128,0,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_RIGHT_SHOULDER:
			return "[img region=160,0,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_DPAD_UP:
			return "[img region=64,32,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_DPAD_DOWN:
			return "[img region=128,32,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_DPAD_LEFT:
			return "[img region=32,32,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_DPAD_RIGHT:
			return "[img region=96,32,32,32]" + _get_glyph_image_path() + "[/img]"
	
	return ""

func _get_playstation_button(button : JoyButton) -> String:
	match button:
		JoyButton.JOY_BUTTON_A:
			return "[img region=0,96,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_B:
			return "[img region=32,96,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_X:
			return "[img region=96,96,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_Y:
			return "[img region=64,96,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_BACK:
			return "[img region=160,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_GUIDE:
			return "[img region=128,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_START:
			return "[img region=128,064,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_LEFT_STICK:
			return "[img region=64,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_RIGHT_STICK:
			return "[img region=96,64,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_LEFT_SHOULDER:
			return "[img region=128,96,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_RIGHT_SHOULDER:
			return "[img region=160,96,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_DPAD_UP:
			return "[img region=64,32,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_DPAD_DOWN:
			return "[img region=128,32,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_DPAD_LEFT:
			return "[img region=32,32,32,32]" + _get_glyph_image_path() + "[/img]"
		JoyButton.JOY_BUTTON_DPAD_RIGHT:
			return "[img region=96,32,32,32]" + _get_glyph_image_path() + "[/img]"
	
	return ""