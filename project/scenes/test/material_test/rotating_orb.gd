extends Node3D

@export var direction : Vector3 = Vector3.RIGHT

func _process(delta):
	rotation_degrees += direction * delta