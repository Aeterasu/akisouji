extends Control

@export var label : RichTextLabel = null

var glyph_image

func _ready():
	glyph_image = ControlGlyphHandler._get_glyph_image_path()

func _physics_process(delta):
	#visible = InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD

	if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD):
		label.text = "[right][img region=0,32,32,32]" + glyph_image + "[/img]" + " - " + tr("MENU_TIP_NAVIGATION") + " " + ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("menu_confirm")[1]) + " - " + tr("MENU_TIP_CONFIRM") + " " + ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("menu_cancel")[1]) + " - " + tr("MENU_TIP_BACK")
	else:
		label.text = "[right][img region=128,128,32,32]" + glyph_image + "[/img]" + " - " + tr("MENU_TIP_NAVIGATION") + " " + "[img region=32,128,32,32]" + glyph_image + "[/img]" + " - " + tr("MENU_TIP_CONFIRM") + " " + "[img region=64,128,32,32]" + glyph_image + "[/img]" + " - " + tr("MENU_TIP_BACK")