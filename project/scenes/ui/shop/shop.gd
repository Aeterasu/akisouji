class_name Shop extends Control

@export var transition_type : TransitionType = TransitionType.FROM_TITLE

@export var button_selection_handler : ButtonSelectionHandler = null
@export var back_button : UIButton = null
@export var lets_sweep_button : UIButton = null

@export var category_select_screen : Control = null
@export var category_select_button_handler : ButtonSelectionHandler = null

@export var category_tools : ShopCategory = null
@export var category_boots : ShopCategory = null

@export var button_category_tools : ShopCategoryButton = null
@export var button_category_boots : ShopCategoryButton = null

var focus_level : int = 0:
	set(value):
		if (value > 1):
			value = 0

		if (value == 0):
			button_selection_handler._enable_all_buttons()

			if (!is_in_category):
				category_select_button_handler._disable_all_buttons()
			else:
				current_category.button_selection_handler._disable_all_buttons()

		elif (value > 0):
			button_selection_handler._disable_all_buttons()

			if (!is_in_category):
				category_select_button_handler._enable_all_buttons()
			else:
				current_category.button_selection_handler._enable_all_buttons()
				current_category.button_selection_handler._select_first_button()

		focus_level = value

var current_category : ShopCategory = null
var is_in_category : bool = false

enum TransitionType
{
	FROM_TITLE,
	FROM_GAME,
}

func _ready():
	button_selection_handler.on_button_pressed.connect(_on_button_pressed)
	
	category_select_button_handler.on_button_pressed.connect(_on_category_button_pressed)

	focus_level = 1

func _process(delta):
	if (Input.is_action_just_pressed("gamepad_dpad_up") or Input.is_action_just_pressed("player_move_forward") or Input.is_action_just_pressed("gamepad_dpad_down") or Input.is_action_just_pressed("player_move_backwards")):
		focus_level += 1

		if (focus_level == 0):
			button_selection_handler._next_button()
		else:
			category_select_button_handler._next_button()

	if (Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("pause")):
		_on_back_button_pressed()

func _on_button_pressed(button : UIButton):
	match (button):
		back_button:
			_on_back_button_pressed()
		lets_sweep_button:
			if (transition_type == TransitionType.FROM_TITLE):
				SceneTransitionHandler.instance._load_game_scene()

func _on_category_button_pressed(button : UIButton):
	if (current_category):
		current_category._deselect()

	category_select_screen.hide()
	category_select_button_handler._disable_all_buttons()

	is_in_category = true

	match (button):
		button_category_tools:
			current_category = category_tools._select()
		button_category_boots:
			current_category = category_boots._select()

func _on_back_button_pressed():
	if (current_category):
		current_category._deselect()
		category_select_screen.show()
		is_in_category = false

	# TODO: back to stage select/close inventory