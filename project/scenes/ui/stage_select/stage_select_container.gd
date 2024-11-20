class_name StageSelectContainer extends Control

@export var container : HBoxContainer = null
@export var offset : float = 0.0

func _ready() -> void:
	pass

func _process(delta):
	container.set("theme_override_constants/separation", _get_target_offset())
	pass

func _get_target_offset():
	return offset * (1 - (1280 / size.x))