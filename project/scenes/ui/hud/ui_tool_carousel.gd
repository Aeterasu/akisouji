class_name UIToolCarousel extends Control

@export var tool_origin : Control = null

@export var tool_left_animated : TextureRect = null
@export var tool_left : TextureRect = null
@export var tool_center : TextureRect = null
@export var tool_right : TextureRect = null
@export var tool_right_animated : TextureRect = null

@export var arrow_right : TextureRect = null
@export var arrow_left : TextureRect = null

@export var semi_transparent_color : Color = Color(1.0, 1.0, 1.0, 1.0)

@export var label : Label = null
@export var tooltip_label : RichTextLabel = null

@export var arrow_right_tooltip_label : RichTextLabel = null
@export var arrow_left_tooltip_label : RichTextLabel = null

@export var icon_garbage_bag : TextureRect = null

@export var audio_accent_1 : AudioStreamPlayer = null

func _ready():
    icon_garbage_bag.hide()

    _update_label()
    GlobalSettings.on_locale_updated.connect(_update_label)

func _update_label():
    if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD):
        arrow_right_tooltip_label.text = "[center]" + ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_next_tool")[1])
        arrow_left_tooltip_label.text = "[center]" + ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_previous_tool")[1])
    elif (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE):
        arrow_right_tooltip_label.text = "[center]" + ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_next_tool")[2])
        arrow_left_tooltip_label.text = "[center]" + ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_previous_tool")[2])