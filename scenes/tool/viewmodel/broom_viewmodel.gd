class_name BroomViewmodel extends Node3D

@export var animation_player : AnimationPlayer = null

@export var allow_animation : bool = true

@export var walk_cycle_speed : float = 5.0
@export var walk_cycle_direction : Vector3 = Vector3()

var walk_multiplier : float = 1.0
var sin_timer : float = 0.0

signal on_broom

func _ready():
	_animate_idle()

func _physics_process(delta):
	sin_timer += delta * walk_cycle_speed * walk_multiplier
	position = Vector3(walk_cycle_direction.x * sin(sin_timer), walk_cycle_direction.y * sin(sin_timer * 2), walk_cycle_direction.z * sin(sin_timer)) * walk_multiplier

func _animate_broom() -> void:
	animation_player.stop(true)
	animation_player.play("broom")

func _animate_idle() -> void:
	animation_player.play("idle")

func _attempt_brooming() -> void:
	if (!allow_animation):
		return

	allow_animation = false

	_animate_broom()

func _broom():
	on_broom.emit()