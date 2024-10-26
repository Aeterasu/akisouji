class_name SettingsCategory extends Control

@export var button_selection_handler : ButtonSelectionHandler = null
@export var back_button : UIButton = null

var target_alpha : float = 1.0

signal on_back_button_pressed

func _ready() -> void:
    button_selection_handler.on_button_pressed.connect(_on_button_pressed)

func _process(delta):
    modulate = modulate.lerp(Color(1.0, 1.0, 1.0, target_alpha), 6.0 * delta)

func _on_button_pressed(button : UIButton) -> void:
    if (button is SettingsButton):
        var settings_button = button as SettingsButton
        if (settings_button.setting_toggle):
            settings_button.setting_toggle._toggle()

    if (button == back_button):
        on_back_button_pressed.emit(self)