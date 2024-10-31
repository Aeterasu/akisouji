extends SettingsSlider

func  _ready():
    super()

    min_value = GlobalSettings.min_mouse_sensitivity
    max_value = GlobalSettings.max_mouse_senitivity
    step = 0.01

    value = GlobalSettings.mouse_sensitivity

    setting_text = str(value)

func _on_drag(new_value : float):
    if (!is_dragging):
        return

    GlobalSettings.mouse_sensitivity = value
    setting_text = str(value)