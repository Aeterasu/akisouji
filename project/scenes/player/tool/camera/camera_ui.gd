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
		label.text = "[left][img region=160,0,32,32]" + glyph_image + "[/img]" + " - " + tr("CAMERA_TOOLTIP_ZOOM_IN") + "\n" + "[img region=128,0,32,32]" + glyph_image + "[/img]" + " - " + tr("CAMERA_TOOLTIP_ZOOM_OUT") + "\n" + "[img region=224,0,32,32]" + glyph_image + "[/img]" + " - " + tr("CAMERA_TOOLTIP_PHOTO") + "\n" + "[img region=192,0,32,32]" + glyph_image + "[/img]" + " - " + tr("CAMERA_TOOLTIP_BACK") + "[/left]"