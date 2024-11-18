extends SettingsSlider

@export var bus : StringName

func  _ready():
    super()

    min_value = 0.0
    max_value = 1.0
    step = 0.01
    
    match (bus):
        "Master":
            value = GlobalSettings.master_volume
        "SFX":
            value = GlobalSettings.sfx_volume
        "Ambience":
            value = GlobalSettings.ambience_volume
        "Music":
            value = GlobalSettings.music_volume

    setting_text = str(round(value * 100)) + "%"

func _on_drag(new_value : float):
    if (!is_dragging):
        return

    match (bus):
        "Master":
            GlobalSettings.master_volume = value
        "SFX":
            GlobalSettings.sfx_volume = value
        "Ambience":
            GlobalSettings.ambience_volume = value
        "Music":
            GlobalSettings.music_volume = value

    setting_text = str(round(value * 100)) + "%"

    super(new_value)