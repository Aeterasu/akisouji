class_name PlayerCamera extends Camera3D

@export var photo_mode_start_fov : float = 65.0
@export var photo_mode_min_fov : float = 30.0
@export var photo_mode_max_fov : float = 100.0
@export var zoom_speed : float = 15.0
@export var lerp_weight : float = 5.0

var in_photo_mode : bool = false

var photo_mode_target_fov : float = 65.0
var photo_mode_current_fov : float = 65.0

func _ready():
	fov = GlobalSettings.fov
	photo_mode_target_fov = photo_mode_start_fov

func _process(delta):
	if (Input.is_action_pressed("photo_mode_zoom_out")):
		photo_mode_target_fov += zoom_speed * delta
	elif (Input.is_action_pressed("photo_mode_zoom_in")):
		photo_mode_target_fov -= zoom_speed * delta

	photo_mode_target_fov = clamp(photo_mode_target_fov, photo_mode_min_fov, photo_mode_max_fov)
	photo_mode_current_fov = lerp(photo_mode_current_fov, photo_mode_target_fov, lerp_weight * delta)

	if (!in_photo_mode):
		fov = GlobalSettings.fov
	else:
		fov = photo_mode_current_fov

func _input(event):
	if in_photo_mode and event is InputEventMouseButton and event.is_pressed():
		# zoom in
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			photo_mode_target_fov -= int(zoom_speed * 0.5)
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			photo_mode_target_fov += int(zoom_speed * 0.5)

func _enter_photo_mode() -> void:
	photo_mode_target_fov = photo_mode_start_fov
	photo_mode_current_fov = photo_mode_current_fov
	in_photo_mode = true

func _exit_photo_mode() -> void:
	fov = GlobalSettings.fov
	photo_mode_target_fov = photo_mode_start_fov
	photo_mode_current_fov = photo_mode_current_fov
	in_photo_mode = false