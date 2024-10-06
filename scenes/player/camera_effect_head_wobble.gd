extends Node3D

@export var velocity_component : VelocityComponent = null
@export var player : Player = null

@export_group("Wobble effect settings")
@export var position_offset = Vector3(0.0, 0.1, 0.0)
@export var position_speed = 16.0
@export var rotation_degrees_offset = Vector3(0.0, 0.0, 1.0)
@export var rotation_speed = 8.0

var position_sin_tick : float = 0.0
var rotation_sin_tick : float = 0.0

var strength : float = 0.0

func _physics_process(delta):
	if (!GlobalSettings.camera_wobble_enabled):
		position = Vector3.ZERO
		rotation_degrees = Vector3.ZERO
		return

	if (!player.is_on_floor()):
		strength = lerp(strength, 0.0, 4.0 * delta)
	else:
		strength = lerp(strength, velocity_component.current_velocity.length() / velocity_component.speed, 8.0 * delta)

	position_sin_tick += position_speed * delta
	rotation_sin_tick += rotation_speed * delta

	position = position_offset * sin(position_sin_tick) * strength
	rotation_degrees = rotation_degrees_offset * sin(rotation_sin_tick) * strength
