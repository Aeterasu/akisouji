class_name PlayerCamera extends Camera3D

@export var photo_mode_fov : float = 65.0

func _ready():
	fov = GlobalSettings.fov

func _enter_photo_mode() -> void:
	fov = photo_mode_fov

func _exit_photo_mode() -> void:
	fov = GlobalSettings.fov