class_name SettingsCategory extends Control

@export var category_name_key : String = ""

@export var button_hold_to_fast_adjust_duration : float = 0.4
@export var adjust_rate : float = 0.15

@export var button_selection_handler : ButtonSelectionHandler = null
@export var back_button : UIButton = null

var target_alpha : float = 1.0

var button_hold_ticks : float = 0.0
var adjust_ticks : float = 0.0

signal on_back_button_pressed

func _ready() -> void:
	button_selection_handler.on_button_pressed.connect(_on_button_pressed)

func _process(delta):
	modulate = modulate.lerp(Color(1.0, 1.0, 1.0, target_alpha), 6.0 * delta)

	if (Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("menu_cancel")):
		on_back_button_pressed.emit(self)

	if ((button_selection_handler.current_button is SettingsButton)):
		var slider = (button_selection_handler.current_button as SettingsButton).setting_slider
		var toggle = (button_selection_handler.current_button as SettingsButton).setting_toggle
		if (slider):
			if (Input.is_action_just_pressed("gamepad_dpad_left") or Input.is_action_just_pressed("player_move_left")):
				_adjust_slider_by_gamepad_step(slider, -1.0)
			if (Input.is_action_just_pressed("gamepad_dpad_right") or Input.is_action_just_pressed("player_move_right")):
				_adjust_slider_by_gamepad_step(slider, 1.0)

			if (Input.is_action_pressed("gamepad_dpad_left") or Input.is_action_pressed("player_move_left") or Input.is_action_pressed("gamepad_dpad_right") or Input.is_action_pressed("player_move_right")):
				button_hold_ticks += delta
			else:
				button_hold_ticks = 0.0
				adjust_ticks = 0.0

			if (button_hold_ticks >= button_hold_to_fast_adjust_duration):
				adjust_ticks += delta

				var adjust_sign = 1.0

				if (Input.is_action_pressed("gamepad_dpad_left") or Input.is_action_pressed("player_move_left")):
					adjust_sign = -1.0

				if (adjust_ticks >= adjust_rate):
					_adjust_slider_by_gamepad_step(slider, adjust_sign)
					adjust_rate = 0.0

		if (toggle):
			if (Input.is_action_just_pressed("gamepad_dpad_left") or Input.is_action_just_pressed("player_move_left")):
				toggle._toggle()
				SfxDeconflicter.play(button_selection_handler.current_button.audio_accent_2)
			if (Input.is_action_just_pressed("gamepad_dpad_right") or Input.is_action_just_pressed("player_move_right")):
				toggle._alt_toggle()
				SfxDeconflicter.play(button_selection_handler.current_button.audio_accent_2)


func _adjust_slider_by_gamepad_step(slider : SettingsSlider, adjust_sign : float = 1.0):
	slider.is_dragging = true
	slider.value += slider.gamepad_step * sign(adjust_sign)
	slider._on_drag(0.0)
	slider.set_deferred("is_dragging", false)

func _on_button_pressed(button : UIButton) -> void:
	if (button is SettingsButton):
		var settings_button = button as SettingsButton
		if (settings_button.setting_toggle):
			settings_button.setting_toggle._check_toggle()

	if (button == back_button):
		on_back_button_pressed.emit(self)