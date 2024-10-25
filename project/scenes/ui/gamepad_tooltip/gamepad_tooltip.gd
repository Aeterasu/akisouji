extends Control

@export var label : RichTextLabel = null

var glyph_image

func _ready():
	glyph_image = ControlGlyphHandler._get_glyph_image_path()

func _physics_process(delta):
	visible = InputDeviceCheck.input_device == InputDeviceCheck.InputDevice.GAMEPAD

	label.text = "[right][img region=0,32,32,32]" + glyph_image + "[/img]" + " - " + tr("MENU_TIP_NAVIGATION") + " " + "[img region=0,0,32,32]" + glyph_image + "[/img]" + " - " + tr("MENU_TIP_CONFIRM") + " " + "[img region=32,0,32,32]" + glyph_image + "[/img]" + " - " + tr("MENU_TIP_BACK")