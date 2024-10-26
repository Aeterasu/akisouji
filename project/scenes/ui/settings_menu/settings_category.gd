class_name SettingsCategory extends Control

@export var category_name_key : String = ""

@export var button_selection_handler : ButtonSelectionHandler = null
@export var back_button : UIButton = null

var target_alpha : float = 1.0

signal on_back_button_pressed

func _ready() -> void:
	button_selection_handler.on_button_pressed.connect(_on_button_pressed)

func _process(delta):
	modulate = modulate.lerp(Color(1.0, 1.0, 1.0, target_alpha), 6.0 * delta)

	if (Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("menu_cancel")):
		on_back_button_pressed.emit(self)

	if ((button_selection_handler.current_button is SettingsButton)):
		var slider = (button_selection_handler.current_button as SettingsButton).setting_slider
		if (slider):
			if (Input.is_action_just_pressed("gamepad_dpad_left") or Input.is_action_just_pressed("player_move_left")):
				slider.value -= slider.gamepad_step
				slider._on_drag(0.0)
			if (Input.is_action_just_pressed("gamepad_dpad_right") or Input.is_action_just_pressed("player_move_right")):
				slider.value += slider.gamepad_step
				slider._on_drag(0.0)

func _on_button_pressed(button : UIButton) -> void:
	if (button is SettingsButton):
		var settings_button = button as SettingsButton
		if (settings_button.setting_toggle):
			settings_button.setting_toggle._toggle()

	if (button == back_button):
		on_back_button_pressed.emit(self)