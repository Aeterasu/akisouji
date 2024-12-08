class_name UITutorial extends Control

@export var tutorial_stage : int = 1:
	set(value):
		tutorial_stage = value

		in_animation = true

		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.4)
		tween.tween_callback(func(): label.text = tr("TUTORIAL_" + str(tutorial_stage)))
		tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.4)
		tween.tween_callback(func(): in_animation = false).set_delay(0.4)

@export var is_shown : bool = false:
	set(value):
		is_shown = value

		in_animation = true

		if (!value):
			var tween = get_tree().create_tween()
			tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.4)
			tween.tween_callback(func(): in_animation = false).set_delay(0.4)
		else:
			var tween = get_tree().create_tween()
			tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.4)
			tween.tween_callback(func(): in_animation = false).set_delay(0.4)

@export var label : RichTextLabel = null

var in_animation : bool = false

var ticks : float = 0.0

var stage_3_flag : bool = false
var stage_3_hide_flag : bool = false

var stage_4_flag : bool = false
var stage_4_hide_flag : bool = false

func _ready() -> void:
	tutorial_stage = 1

func _process(delta):
	var glyph_image = ControlGlyphHandler._get_glyph_image_path()

	if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD):
		label.text = label.text.replace("[LMB]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_primary")[1]))
		label.text = label.text.replace("[WASD]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_move_forward")[1]))
		label.text = label.text.replace("[MOUSE]", "[img region=32,64,32,32]" + glyph_image + "[/img]")

	elif (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE):
		label.text = label.text.replace("[LMB]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_primary")[0]))

		var wasd = "["
		wasd += ControlGlyphHandler._get_key_string(InputMap.action_get_events("player_move_forward")[0])
		wasd += ControlGlyphHandler._get_key_string(InputMap.action_get_events("player_move_left")[0])
		wasd += ControlGlyphHandler._get_key_string(InputMap.action_get_events("player_move_backwards")[0])
		wasd += ControlGlyphHandler._get_key_string(InputMap.action_get_events("player_move_right")[0])
		wasd += "]"
		label.text = label.text.replace("[WASD]", wasd)

		label.text = label.text.replace("[MOUSE]", "[img region=128,128,32,32]" + glyph_image + "[/img]")