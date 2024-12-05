extends SettingsSlider

func  _ready():
    super()

    min_value = GlobalSettings.min_gamepad_sensitivity
    max_value = GlobalSettings.max_gamepad_senitivity
    step = 0.01

    value = GlobalSettings.gamepad_sensitvity

    setting_text = str(value)

func _on_drag(new_value : float):
    if (!is_dragging):
        return

    GlobalSettings.gamepad_sensitvity = value
    setting_text = str(value)

    super(new_value)