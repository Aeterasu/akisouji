extends SettingsFunction

func _ready():
    _update_text()

func _toggle() -> void:
    GlobalSettings.show_fps_counter = not GlobalSettings.show_fps_counter
    _update_text()

func _alt_toggle() -> void:
    _toggle()

func _update_text():
    if (GlobalSettings.show_fps_counter):
        setting_text = tr("SETTINGS_KEY_ON")
    else:
        setting_text = tr("SETTINGS_KEY_OFF")