class_name CameraUI extends Control

@export var label : RichTextLabel = null

var glyph_image

static var instance : CameraUI = null

func _ready():
	instance = self

	glyph_image = ControlGlyphHandler._get_glyph_image_path()

	hide()

func _process(delta):
	if (!visible):
		return

	if (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.KEYBOARD_MOUSE):
		label.text = "[left][img region=160,128,32,32]" + glyph_image + "[/img]" + " - " + tr("CAMERA_TOOLTIP_ZOOM") + "\n" + "[img region=32,128,32,32]" + glyph_image + "[/img]" + " - " + tr("CAMERA_TOOLTIP_PHOTO") + "\n" + "[img region=64,128,32,32]" + glyph_image + "[/img]" + " - " + tr("CAMERA_TOOLTIP_BACK") + "\n" + "[/left]"
	elif (InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD):
		var zoom_in : String = ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("photo_mode_zoom_in")[1])
		var zoom_out : String = ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("photo_mode_zoom_out")[1])
		var player_action_primary : String = ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_primary")[1])
		var player_action_secondary : String = ControlGlyphHandler._get_glyph_bbcode(InputMap.action_get_events("player_action_secondary")[1])

		label.text = "[left]" + zoom_in + " - " + tr("CAMERA_TOOLTIP_ZOOM_IN") + "\n" + zoom_out + " - " + tr("CAMERA_TOOLTIP_ZOOM_OUT") + "\n" + player_action_primary + " - " + tr("CAMERA_TOOLTIP_PHOTO") + "\n" + player_action_secondary + " - " + tr("CAMERA_TOOLTIP_BACK") + "[/left]"