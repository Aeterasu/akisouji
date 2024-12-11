extends Node

var locale_count : int = 3

func _int_to_locale(id : int) -> String:
	match id:
		0:
			return "en"
		1:
			return "ru"
		2:
			return "es"

	return "en"

func _locale_to_int(locale_name : String) -> int:
	match locale_name:
		"en":
			return 0
		"ru":
			return 1
		"es":
			return 2

	return 0

func _locale_to_text_key(locale_name : String) -> String:
	match locale_name:
		"en":
			return "LOCALE_NAME_EN"
		"ru":
			return "LOCALE_NAME_RU"
		"es":
			return "LOCALE_NAME_ES"

	return "LOCALE_NAME_EN"