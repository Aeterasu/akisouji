class_name CameraUI extends CanvasLayer

static var instance : CameraUI = null

func _ready():
	instance = self

	hide()