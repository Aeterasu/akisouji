class_name UIGarbageBagPopup extends Control

@export var label : RichTextLabel = null 

var is_bag_full : bool = false:
	set(value):
		if (is_bag_full == value):
			return

		is_bag_full = value

		if (value):
			var tween = get_tree().create_tween()
			tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
		else:
			var tween = get_tree().create_tween()
			tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.1)

func _ready():
	modulate = Color(0.0, 0.0, 0.0, 0.0)

func _process(delta):
	if (is_bag_full):
		label.text = "[center]" + tr("GARBAGE_BAG_FULL_2")
		
		if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD):
			label.text = label.text.replace("[button]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_secondary")[1]))
		elif (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE):
			label.text = label.text.replace("[button]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_secondary")[0]))