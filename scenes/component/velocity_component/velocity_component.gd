class_name VelocityComponent extends Node

@export_group("Speed")
@export var speed : float = 1.0

@export_group("Smooth Velocity")
@export var smooth_toggle : bool = false
@export var accel_weight : float = 3.0
@export var decel_weight : float = 1.5

var input_direction = Vector2()
var target_velocty = Vector2()

var current_velocity = Vector2()

func _physics_process(delta):
	target_velocty = input_direction * speed

	if (smooth_toggle):
		if (input_direction.length() > 0.0):
			current_velocity = current_velocity.lerp(target_velocty, accel_weight * delta)
		else:
			current_velocity = current_velocity.lerp(target_velocty, decel_weight * delta)
	else:
		current_velocity = target_velocty