extends SettingsFunction

func _ready():
    _update_text()

func _toggle() -> void:
    GlobalSettings.toggle_to_clean = not GlobalSettings.toggle_to_clean
    _update_text()

func _alt_toggle() -> void:
    _toggle()

func _update_text():
    if (GlobalSettings.toggle_to_clean):
        setting_text = tr("SETTINGS_KEY_ON")
    else:
        setting_text = tr("SETTINGS_KEY_OFF")