class_name UIInteractionTooltip extends Control

@export var lerp_weight : float = 10.0
@export var label : RichTextLabel = null

var show_tooltip : bool = false

func _process(delta):
    label.text = "[left]" + tr("INTERACTION_TOOLTIP_PICKUP")

    if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD):
        label.text = label.text.replace("[button]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_primary")[1]))
    elif (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE):
        label.text = label.text.replace("[button]", ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_primary")[0]))

    if (show_tooltip):
        modulate = modulate.lerp(Color(1.0, 1.0, 1.0, 1.0), lerp_weight * delta)
    else:
        modulate = modulate.lerp(Color(0.0, 0.0, 0.0, 0.0), lerp_weight * delta)