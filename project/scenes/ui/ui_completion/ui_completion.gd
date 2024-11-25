class_name UICompletion extends Control

@export var initial_popup : Control = null

func _ready() -> void:
	hide()
	initial_popup.modulate = Color(0.0, 0.0, 0.0, 0.0)
	pass

func _show_initial_popup():
	show()
	var tween = get_tree().create_tween()
	tween.tween_property(initial_popup, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)