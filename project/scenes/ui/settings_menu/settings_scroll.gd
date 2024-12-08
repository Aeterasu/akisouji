class_name SettingsScroll extends Control

@export var max_scroll : float = 548.0
@export var min_scroll : float = 0.0

var target_scroll : float = 0.0

var current_scroll : float = 0.0

func _process(delta):
    current_scroll = lerp(current_scroll, target_scroll, 8 * delta)
    position.y = current_scroll