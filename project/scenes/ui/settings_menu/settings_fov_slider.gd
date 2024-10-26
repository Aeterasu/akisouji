extends SettingsSlider

func  _ready():
    super()

    value = GlobalSettings.fov
    min_value = GlobalSettings.min_fov
    max_value = GlobalSettings.max_fov

    setting_text = str(value)

func _on_drag(new_value : float):
    GlobalSettings.fov = value
    setting_text = str(value)