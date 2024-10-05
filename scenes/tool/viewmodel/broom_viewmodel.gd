class_name BroomViewmodel extends Node3D

@export var animation_player : AnimationPlayer = null

@export var allow_animation : bool = true

signal on_broom

func _ready():
	_animate_idle()

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
	print("meow")