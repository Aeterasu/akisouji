class_name SettingsFunction extends Node

var is_alt_toggle : bool = false

var setting_text = ""

func _check_toggle() -> void:
	if (!is_alt_toggle):
		_toggle()
	else:
		_alt_toggle()

func _toggle() -> void:
	pass

func _alt_toggle() -> void:
	pass