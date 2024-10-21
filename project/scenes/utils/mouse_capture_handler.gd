class_name MouseCaptureHandler extends Node

@export var mode : Input.MouseMode = Input.MOUSE_MODE_VISIBLE

func _ready():
	Input.mouse_mode = mode