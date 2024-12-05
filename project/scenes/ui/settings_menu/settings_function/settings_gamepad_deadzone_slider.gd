extends SettingsSlider

func  _ready():
    super()

    min_value = 0.0
    max_value = 1.0
    step = 0.01

    value = GlobalSettings.gamepad_deadzone

    setting_text = str(value)

func _on_drag(new_value : float):
    if (!is_dragging):
        return

    GlobalSettings.gamepad_deadzone = value
    setting_text = str(value)

    super(new_value)