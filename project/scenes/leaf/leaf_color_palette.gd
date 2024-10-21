class_name LeafColorPalette extends Node

@export var colors : Array[Color] = []
@export var fallback_color : Color = Color(1.0, 1.0, 1.0)

func _ready():
	pass

func _get_random_color():
	if len(colors) <= 0:
		return fallback_color
	else:
		return colors.pick_random()

func _get_fallback_color():
	return fallback_color