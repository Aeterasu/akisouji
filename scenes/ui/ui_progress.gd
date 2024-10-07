class_name UIProgress extends Control

@export var label : Label = null

var max_value : int = 0
var current_value : int = 0

func _process(delta) -> void:
	label.text = "Progress: " + str(_get_progress()) + "%"

func _get_progress() -> float:
	if (current_value <= 0):
		return 0.0

	return clamp(ceil(float(current_value) / float(max_value) * 100.0), 0.0, 100.0)