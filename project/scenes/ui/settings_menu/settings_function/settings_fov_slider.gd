extends SettingsSlider

func  _ready():
    super()

    min_value = GlobalSettings.min_fov
    max_value = GlobalSettings.max_fov
    value = GlobalSettings.fov

    setting_text = str(value)

func _on_drag(new_value : float):
    if (!is_dragging):
        return

    super(new_value)

    GlobalSettings.fov = value
    setting_text = str(value)