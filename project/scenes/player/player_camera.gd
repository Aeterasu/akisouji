class_name PlayerCamera extends Camera3D

@export var photo_mode_fov : float = 65.0

var in_photo_mode : bool = false

func _ready():
	fov = GlobalSettings.fov

func _process(delta):
	if (!in_photo_mode):
		fov = GlobalSettings.fov

func _enter_photo_mode() -> void:
	fov = photo_mode_fov
	in_photo_mode = true

func _exit_photo_mode() -> void:
	fov = GlobalSettings.fov
	in_photo_mode = false