class_name Shop extends Control

@export var transition_type : TransitionType = TransitionType.FROM_TITLE

@export var back_button : UIButton = null
@export var tools_button : UIButton = null
@export var boots_button : UIButton = null

@export var category_select_screen : Control = null
@export var category_select_button_handler : ButtonSelectionHandler = null

@export var category_tools : ShopCategory = null
@export var category_boots : ShopCategory = null

var current_category : ShopCategory = null
var is_in_category : bool = false

var reset_entry_selection : bool = true

signal on_shop_closed

enum TransitionType
{
	FROM_TITLE,
	FROM_GAME,
}

func _ready():
	category_select_button_handler.on_button_pressed.connect(_on_category_select_button_pressed)

	category_select_button_handler._enable_all_buttons()

	modulate = Color(0.0, 0.0, 0.0, 0.0)

	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)

func _process(delta):
	if (Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("menu_cancel")):
		_on_back_button_pressed()

func _on_category_select_button_pressed(button : UIButton):
	match (button):
		back_button:
			_on_back_button_pressed()
		tools_button:
			_on_category_select()
			is_in_category = true
			current_category = category_tools._select()
		boots_button:
			is_in_category = true
			_on_category_select()
			current_category = category_boots._select()

func _on_back_button_pressed():
	if (is_in_category):
		current_category.button_selection_handler._disable_all_buttons()
		category_select_button_handler._enable_all_buttons()
		current_category._deselect()
		category_select_screen.show()
		current_category = null
		is_in_category = false
		return

	category_select_button_handler._disable_all_buttons()

	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.2)
	tween.tween_callback(on_shop_closed.emit).set_delay(0.2)
	tween.tween_callback(_back_func).set_delay(0.2)

func _on_category_select() -> void:
	category_select_screen.hide()
	category_select_button_handler._disable_all_buttons()

func _back_func() -> void:
	if (transition_type == TransitionType.FROM_TITLE):
		SceneTransitionHandler.instance._load_stage_select_scene()	