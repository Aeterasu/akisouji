extends MeshInstance3D

@export var rot_count : int = 250000
@export var label : Label = null

func _ready():
	var start_time : int = Time.get_ticks_msec()

	for i in rot_count:
		_rotate_random()

	var end_time : int = Time.get_ticks_msec()
	var duration : int = end_time - start_time

	label.text += str("Time taken with GDScript: ", duration, "ms\n")

	prints("Time taken with GDScript: ", duration, "ms")

func _rotate_random() -> void:
	rotation += Vector3(1, 0, 0) * randf() + Vector3(0, 1, 0) * randf() + Vector3(0, 0, 1) * randf()