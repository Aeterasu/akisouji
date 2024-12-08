class_name SettingsKeybind extends Node

@export var input_action : String = ""
@export var keybind_label : RichTextLabel = null

@export var device : InputDeviceCheck.InputDevice = InputDeviceCheck.InputDevice.KEYBOARD_MOUSE

var setting_text = ""

var awaiting_input : bool = false

var delay : float = 0.2

signal on_received_input

func _process(delta):
	delay -= delta
	
	if (device == 0):
		keybind_label.text = "[center]" + ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events(input_action)[0])
	if (device == 1):
		keybind_label.text = "[center]" + ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events(input_action)[1])

func _check_toggle() -> void:
	if (device != InputDeviceCheck.input_device):
		return

	_toggle()

func _toggle() -> void:
	if (not awaiting_input):
		delay = 0.2
		awaiting_input = true

func _input(event):
	if (awaiting_input and delay <= 0.0):
		awaiting_input = false
		on_received_input.emit(self)

		if (device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE and (event is InputEventKey or event is InputEventMouseButton)):
			for list in GlobalSettings.bindable_actions:
				var e = InputMap.action_get_events(StringName(list))
				if (len(e) > 0):
					if ((event is InputEventKey) and (e[0] is InputEventKey) and ((event as InputEventKey).physical_keycode == (e[0] as InputEventKey).physical_keycode)):
						print("KEY ALREADY TAKEN")
						return
					elif ((event is InputEventMouseButton) and (e[0] is InputEventMouseButton) and ((event as InputEventMouseButton).button_index == (e[0] as InputEventMouseButton).button_index)):
						print("KEY ALREADY TAKEN")
						return

			var inputs = InputMap.action_get_events(input_action)
			var size = len(inputs)
			
			InputMap.action_erase_events(input_action)

			InputMap.action_add_event(input_action, event)
			
			for i in range(1, size):
				InputMap.action_add_event(input_action, inputs[i])

		elif (device == InputDeviceCheck.InputDevice.GAMEPAD and (event is InputEventJoypadButton or (event is InputEventJoypadMotion and ((event as InputEventJoypadMotion).axis == JOY_AXIS_TRIGGER_LEFT or (event as InputEventJoypadMotion).axis == JOY_AXIS_TRIGGER_RIGHT)))):
			for list in GlobalSettings.bindable_actions:
				var e = InputMap.action_get_events(StringName(list))
				if (len(e) > 0):
					if ((event is InputEventJoypadButton) and (e[0] is InputEventJoypadButton) and ((event as InputEventJoypadButton).button_index == (e[0] as InputEventJoypadButton).button_index)):
						print("KEY ALREADY TAKEN")
						return
					elif ((event is InputEventJoypadMotion) and (e[0] is InputEventJoypadMotion) and ((event as InputEventJoypadMotion).axis == (e[0] as InputEventJoypadMotion).axis)):
						print("KEY ALREADY TAKEN")
						return

			var inputs = InputMap.action_get_events(input_action)
			var size = len(inputs)
			
			InputMap.action_erase_events(input_action)

			InputMap.action_add_event(input_action, inputs[0])
			InputMap.action_add_event(input_action, event)
			
			if (size > 1):
				for i in range(2, size):
					InputMap.action_add_event(input_action, inputs[i])

		else:
			return