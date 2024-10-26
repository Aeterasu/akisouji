extends SettingsFunction

func _ready():
    _update_text()

func _toggle() -> void:
    GlobalSettings.fullscreen = not GlobalSettings.fullscreen
    _update_text()

func _alt_toggle() -> void:
    _toggle()

func _update_text():
    if (GlobalSettings.fullscreen):
        setting_text = "SETTINGS_KEY_ON"
    else:
        setting_text = "SETTINGS_KEY_OFF"