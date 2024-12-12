extends SettingsFunction

func _ready():
    _update_text()

    GlobalSettings.on_locale_updated.connect(_update_text)

func _toggle() -> void:
    GlobalSettings.vsync_enabled = not GlobalSettings.vsync_enabled
    _update_text()

func _alt_toggle() -> void:
    _toggle()

func _update_text():
    if (GlobalSettings.vsync_enabled):
        setting_text = tr("SETTINGS_KEY_ON")
    else:
        setting_text = tr("SETTINGS_KEY_OFF")