extends SettingsFunction

func _ready():
    _update_text()

    GlobalSettings.on_locale_updated.connect(_update_text)

func _toggle() -> void:
    GlobalSettings.camera_wobble_enabled = not GlobalSettings.camera_wobble_enabled
    _update_text()

func _alt_toggle() -> void:
    _toggle()

func _update_text():
    if (GlobalSettings.camera_wobble_enabled):
        setting_text = tr("SETTINGS_KEY_ON")
    else:
        setting_text = tr("SETTINGS_KEY_OFF")