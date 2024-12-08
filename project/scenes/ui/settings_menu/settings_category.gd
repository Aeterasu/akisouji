class_name SettingsCategory extends Control

@export var category_name_key : String = ""

@export var button_hold_to_fast_adjust_duration : float = 0.4
@export var adjust_rate : float = 0.15

@export var button_selection_handler : ButtonSelectionHandler = null
@export var back_button : UIButton = null

@export var settings : SettingsMenu = null

var target_alpha : float = 1.0

var button_hold_ticks : float = 0.0
var adjust_ticks : float = 0.0

var button_id_preserve : int = 0

var keybind_delay : float = 0.2

var scroll

var selected : bool = false

var block_input : bool = false

signal on_back_button_pressed

func _ready() -> void:
	button_selection_handler.on_button_pressed.connect(_on_button_pressed)
	button_selection_handler.on_scroll_button_pressed.connect(_on_scroll_button_pressed)
	scroll = get_node_or_null("Control/Scroll")

func _on_scroll_button_pressed():
	if (scroll and button_selection_handler.current_selection_id < len(button_selection_handler.buttons) - 1):
		(scroll as SettingsScroll).target_scroll = button_selection_handler.current_button.position.y

func _process(delta):
	modulate = modulate.lerp(Color(1.0, 1.0, 1.0, target_alpha), 6.0 * delta)

	keybind_delay -= delta

	if (scroll and scroll is SettingsScroll):
		if (!block_input and selected and Input.is_action_just_released("scroll_up")):
			(scroll as SettingsScroll).target_scroll -= 74
		elif (!block_input and selected and Input.is_action_just_released("scroll_down")):
			(scroll as SettingsScroll).target_scroll += 74
		#elif (!block_input and selected and button_selection_handler.current_button and (Input.is_action_just_pressed("gamepad_dpad_up") or Input.is_action_just_pressed("player_move_forward") or Input.is_action_just_pressed("gamepad_dpad_down") or Input.is_action_just_pressed("player_move_backwards"))):
			#(scroll as SettingsScroll).target_scroll = button_selection_handler.current_button.position.y - 74.0

		#var sc = clamp(button_selection_handler.current_button.position.y - 240.0, 0.0, scroll.max_scroll)
		#(scroll as SettingsScroll).target_scroll = -sc

		var sc = clamp((scroll as SettingsScroll).target_scroll - 240.0, 0.0, scroll.max_scroll)
		(scroll as SettingsScroll).current_scroll = -sc

	if (!block_input and (Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("menu_cancel"))):
		on_back_button_pressed.emit(self)
		GlobalSettings._save_config()

	if ((button_selection_handler.current_button is SettingsButton)):
		var slider = (button_selection_handler.current_button as SettingsButton).setting_slider
		var toggle = (button_selection_handler.current_button as SettingsButton).setting_toggle
		var keybind = (button_selection_handler.current_button as SettingsButton).setting_keybind

		if (slider):
			button_selection_handler.prevent_new_selection = slider.is_dragging

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

		if (keybind):
			if (Input.is_action_just_pressed("menu_confirm") and keybind.device == InputDeviceCheck.input_device and keybind_delay <= 0.0):
				keybind._toggle()
				#show_keybind_popup = true
				button_id_preserve = button_selection_handler.current_selection_id
				button_selection_handler._disable_all_buttons()
				keybind.on_received_input.connect(_on_keybind_input)
				keybind_delay = 0.2
				settings.show_keybind_popup = true
				settings.keybind_popup.label.text = tr("SETTINGS_KEYBIND")
				block_input = true
				return
				
				
func _on_keybind_input(keybind : SettingsKeybind, successfull : bool) -> void:
	if (successfull):
		keybind.on_received_input.disconnect(_on_keybind_input)
		button_selection_handler._enable_all_buttons()
		keybind_delay = 0.2
		button_selection_handler.current_selection_id = button_id_preserve
		button_selection_handler._update_button()
		
		settings.show_keybind_popup = false

		block_input = false
	else:
		settings.keybind_popup.label.text = tr("SETTINGS_KEYBIND_FAILED")
		keybind.keybind_failed_awaiting_input = true
		keybind.delay = 0.2

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
		if (scroll):
			scroll.target_scroll = 0.0
		selected = false
		GlobalSettings._save_config()