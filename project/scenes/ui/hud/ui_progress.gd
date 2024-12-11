class_name UIProgress extends Control

@export var label : Label = null
@export var progress_bar : TextureProgressBar = null
@export var percent_label : Label = null

@export var garbage_bag_label : Label = null

var current_value : float = 0

func _process(delta) -> void:
	percent_label.text = str(clamp(floor((current_value * 100 ) * pow(10, 1)) / pow(10, 1), 0, 100)) + "%"
	progress_bar.value = lerp(progress_bar.value, current_value * 100, 20.0 * delta)