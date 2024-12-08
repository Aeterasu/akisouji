class_name SettingsMenu extends Control

#@export var background : Control = null
@export var scrolling_background : Control = null

@export var on_back_pressed_type : OnBackPressedType = OnBackPressedType.GO_TO_TITLE

@export var button_selection_handler : ButtonSelectionHandler = null

@export var back_button : UIButton = null
@export var button_general : UIButton = null
@export var button_language : UIButton = null
@export var button_keyboard : UIButton = null
@export var button_gamepad : UIButton = null
@export var button_audio : UIButton = null

@export var settings_category_general : SettingsCategory = null
@export var settings_category_language : SettingsCategory = null
@export var settings_category_keyboard : SettingsCategory = null
@export var settings_category_gamepad : SettingsCategory = null
@export var settings_category_audio : SettingsCategory = null

@export var category_name_label : Label = null

@export var category_selected_alpha : float = 1.0
@export var category_unselected_alpha : float = 0.25

var is_in_category : bool = false

enum OnBackPressedType
{
	GO_TO_TITLE,
	QUEUE_FREE,
}

signal on_settings_menu_freed

func _ready():
	button_selection_handler.on_button_pressed.connect(_on_button_pressed)

	settings_category_general.target_alpha = category_unselected_alpha
	settings_category_general.hide()

	settings_category_language.target_alpha = category_unselected_alpha
	settings_category_language.hide()

	settings_category_keyboard.target_alpha = category_unselected_alpha
	settings_category_keyboard.hide()

	settings_category_gamepad.target_alpha = category_unselected_alpha
	settings_category_gamepad.hide()

	settings_category_audio.target_alpha = category_unselected_alpha
	settings_category_audio.hide()

	modulate = Color(0.0, 0.0, 0.0, 0.0)

	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)

func _process(delta):
	if (Input.is_action_just_pressed("pause") || (!is_in_category and Input.is_action_just_pressed("menu_cancel"))):
		_on_back_pressed()

	if (!is_in_category and button_selection_handler.current_button):
		settings_category_general.hide()
		settings_category_language.hide()
		settings_category_keyboard.hide()
		settings_category_gamepad.hide()
		settings_category_audio.hide()

		match (button_selection_handler.current_button):
			button_general:
				settings_category_general.show()
			button_language:
				settings_category_language.show()
			button_keyboard:
				settings_category_keyboard.show()
			button_gamepad:
				settings_category_gamepad.show()
			button_audio:
				settings_category_audio.show()

	if (is_in_category):
		button_selection_handler.buttons_origin.modulate = Color(1.0, 1.0, 1.0, category_unselected_alpha)
	else:
		button_selection_handler.buttons_origin.modulate = Color(1.0, 1.0, 1.0, category_selected_alpha)
		category_name_label.hide()

func _on_button_pressed(button : UIButton):
	if (button == back_button):
		_on_back_pressed()
		return
	else:
		_on_category_button_pressed(button)
		return


func _on_back_pressed() -> void:
	GlobalSettings._save_config()

	on_settings_menu_freed.emit()
	var duration : float = 0.2
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), duration)
	await get_tree().create_timer(duration).timeout

	match on_back_pressed_type:
		OnBackPressedType.GO_TO_TITLE:
			transition(func(): SceneTransitionHandler.instance._load_title_screen_scene())
		OnBackPressedType.QUEUE_FREE:
			self.queue_free()

func _on_category_button_pressed(button : UIButton):
	button_selection_handler._disable_all_buttons()

	var current_category = null

	match (button):
		button_general:
			_on_category_enter(settings_category_general)
			current_category = settings_category_general
		button_language:
			_on_category_enter(settings_category_language)
			current_category = settings_category_language
		button_keyboard:
			_on_category_enter(settings_category_keyboard)
			current_category = settings_category_keyboard
		button_gamepad:
			_on_category_enter(settings_category_gamepad)
			current_category = settings_category_gamepad
		button_audio:
			_on_category_enter(settings_category_audio)
			current_category = settings_category_audio

	if (current_category):
		category_name_label.text = "> " + tr(current_category.category_name_key)
		category_name_label.show()

func _on_category_enter(category: SettingsCategory) -> void:
	category.button_selection_handler._enable_all_buttons()
	category.on_back_button_pressed.connect(_on_category_leave)
	category.target_alpha = category_selected_alpha

	is_in_category = true

func _on_category_leave(category : SettingsCategory) -> void:
	button_selection_handler._enable_all_buttons()

	category.button_selection_handler._disable_all_buttons()
	category.on_back_button_pressed.disconnect(_on_category_leave)
	category.target_alpha = category_unselected_alpha

	is_in_category = false

func transition(callable: Callable):
	var tween = create_tween()
	tween.tween_callback(callable).set_delay(0.2)