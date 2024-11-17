class_name CameraTool extends PlayerTool

@export var sub_viewport : SubViewport = null
@export var viewport_visible : bool = false
@export var mesh : MeshInstance3D = null
@export var camera : Camera3D = null

@export var audio_shutter : AudioStreamPlayer = null

var tickrate : int = 1
var ticks : int = 0

var wish_photo_mode : bool = false

signal on_enter_photo_mode
signal on_exit_photo_mode

func _physics_process(delta):
	super(delta)

	ticks += 1

	if (ticks >= tickrate):
		_update_camera_screen()
		ticks = 0

func _update_camera_screen():
	if (!viewport_visible):
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		return

	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

	camera.global_transform = mesh.global_transform

	var material = mesh.get_surface_override_material(1) as StandardMaterial3D
	var texture = sub_viewport.get_texture()
	material.albedo_texture = texture
	material.emission_texture = texture

func _use_primary() -> void:
	super()

	if (wish_photo_mode):
		CameraUI.instance.hide()
		await get_tree().create_timer(0.1).timeout
		Main.instance._take_screenshot()
		var tween = create_tween()
		tween.tween_property(BlackoutLayer.instance.white_rect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.05)
		tween.tween_property(BlackoutLayer.instance.white_rect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
		await get_tree().create_timer(0.1).timeout
		CameraUI.instance.show()

		audio_shutter.play()

func _use_secondary() -> void:
	super()
	wish_photo_mode = !wish_photo_mode
	allow_switch = !allow_switch

func _enter_photo_mode() -> void:
	on_enter_photo_mode.emit()

func _exit_photo_mode() -> void:
	on_exit_photo_mode.emit()