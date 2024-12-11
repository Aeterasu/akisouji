class_name UITutorial extends Control

@export var tutorial_stage : int = 1:
	set(value):
		tutorial_stage = value

		in_animation = true

		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.4)
		tween.tween_callback(func(): current_text = tr("TUTORIAL_" + str(tutorial_stage)))
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

var current_text : String = "":
	set(value):
		current_text = value
		_update_text()

var in_animation : bool = false

var ticks : float = 0.0

var stage_3_flag : bool = false
var stage_3_hide_flag : bool = false

var stage_4_flag : bool = false
var stage_4_hide_flag : bool = false

var stage_5_flag : bool = false
var stage_5_hide_flag : bool = false

var stage_6_flag : bool = false
var stage_6_hide_flag : bool = false

var glyph_image

func _ready() -> void:
	tutorial_stage = 1

	glyph_image = ControlGlyphHandler._get_glyph_image_path()

	GlobalSettings.on_locale_updated.connect(_update_text)

func _process(delta):
	visible = modulate.a <= 0.01

func _update_text():
	label.text = current_text

	if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD):
		label.text = label.text.replace("[LMB]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_primary")[1]))
		label.text = label.text.replace("[SHIFT]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_sprint")[1]))
		label.text = label.text.replace("[SPACE]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_jump")[1]))
		label.text = label.text.replace("[WASD]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_move_forward")[1]))
		label.text = label.text.replace("[MOUSE]", "[img region=32,64,32,32]" + glyph_image + "[/img]")
		label.text = label.text.replace("[F]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("hint_highlight")[1]))

	elif (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE):
		label.text = label.text.replace("[LMB]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_primary")[0]))
		label.text = label.text.replace("[F]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("hint_highlight")[0]))
		label.text = label.text.replace("[SHIFT]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_sprint")[0]))
		label.text = label.text.replace("[SPACE]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_jump")[0]))

		var wasd = "["
		wasd += ControlGlyphHandler._get_key_string(InputMap.action_get_events("player_move_forward")[0])
		wasd += ControlGlyphHandler._get_key_string(InputMap.action_get_events("player_move_left")[0])
		wasd += ControlGlyphHandler._get_key_string(InputMap.action_get_events("player_move_backwards")[0])
		wasd += ControlGlyphHandler._get_key_string(InputMap.action_get_events("player_move_right")[0])
		wasd += "]"
		label.text = label.text.replace("[WASD]", wasd)

		label.text = label.text.replace("[MOUSE]", "[img region=128,128,32,32]" + glyph_image + "[/img]")