class_name SettingsScroll extends Control

@export var max_scroll : float = 548.0
@export var min_scroll : float = 0.0

var target_scroll : float = 0.0

var current_scroll : float = 0.0
var lerped_scroll : float = 0.0

func _process(delta):
    lerped_scroll = lerp(lerped_scroll, current_scroll, 8 * delta)
    position.y = lerped_scroll