class_name SettingsMenu extends Control

#@export var background : Control = null
@export var scrolling_background : Control = null

@export var on_back_pressed_type : OnBackPressedType = OnBackPressedType.GO_TO_TITLE

@export var button_selection_handler : ButtonSelectionHandler = null

@export var back_button : UIButton = null
@export var button_general : UIButton = null
@export var button_language : UIButton = null
@export var button_keyboard : UIButton = null

@export var settings_category_general : SettingsCategory = null
@export var settings_category_language : SettingsCategory = null
@export var settings_category_keyboard : SettingsCategory = null

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

func _process(delta):
	if (Input.is_action_just_pressed("pause") || (!is_in_category and Input.is_action_just_pressed("menu_cancel"))):
		_on_back_pressed()

	if (!is_in_category and button_selection_handler.current_button):
		settings_category_general.hide()
		settings_category_language.hide()
		settings_category_keyboard.hide()

		match (button_selection_handler.current_button):
			button_general:
				settings_category_general.show()
			button_language:
				settings_category_language.show()
			button_keyboard:
				settings_category_keyboard.show()


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
	match on_back_pressed_type:
		OnBackPressedType.GO_TO_TITLE:
			transition(func(): SceneTransitionHandler.instance._load_scene("res://scenes/title_screen/title_screen.tscn"))
		OnBackPressedType.QUEUE_FREE:
			on_settings_menu_freed.emit()
			self.queue_free()

func _on_category_button_pressed(button : UIButton):
	button_selection_handler._disable_all_buttons()

	var current_category = null

	match (button):
		button_general:
			settings_category_general.button_selection_handler._enable_all_buttons()
			settings_category_general.on_back_button_pressed.connect(_on_category_leave)
			settings_category_general.target_alpha = category_selected_alpha

			is_in_category = true

			current_category = settings_category_general
		button_language:
			settings_category_language.button_selection_handler._enable_all_buttons()
			settings_category_language.on_back_button_pressed.connect(_on_category_leave)
			settings_category_language.target_alpha = category_selected_alpha

			is_in_category = true

			current_category = settings_category_language
		button_keyboard:
			settings_category_keyboard.button_selection_handler._enable_all_buttons()
			settings_category_keyboard.on_back_button_pressed.connect(_on_category_leave)
			settings_category_keyboard.target_alpha = category_selected_alpha

			is_in_category = true

			current_category = settings_category_keyboard

	if (current_category):
		category_name_label.text = current_category.category_name_key
		category_name_label.show()

func _on_category_leave(category : SettingsCategory) -> void:
	button_selection_handler._enable_all_buttons()

	category.button_selection_handler._disable_all_buttons()
	category.on_back_button_pressed.disconnect(_on_category_leave)
	category.target_alpha = category_unselected_alpha

	is_in_category = false

func transition(callable: Callable):
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0), 0.2)
	tween.tween_callback(callable).set_delay(0.2)