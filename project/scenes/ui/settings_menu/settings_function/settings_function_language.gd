extends SettingsFunction

var current_lang : int = 0

func _ready():
	current_lang = LocaleManager._locale_to_int(GlobalSettings.locale)

	_update_text()

func _toggle() -> void:
	current_lang += 1
	_update_locale()

func _alt_toggle() -> void:
	current_lang -= 1
	_update_locale()

func _update_locale() -> void:
	if (current_lang >= LocaleManager.locale_count):
		current_lang = 0

	if (current_lang < 0):
		current_lang = LocaleManager.locale_count - 1

	GlobalSettings.locale = LocaleManager._int_to_locale(current_lang)
	_update_text()

func _update_text():
	setting_text = tr(LocaleManager._locale_to_text_key(GlobalSettings.locale))