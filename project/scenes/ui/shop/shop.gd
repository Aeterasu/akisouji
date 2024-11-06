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

			reset_entry_selection = true

		elif (value > 0):
			button_selection_handler._disable_all_buttons()

			if (!is_in_category):
				category_select_button_handler._enable_all_buttons()
			else:
				current_category.button_selection_handler._enable_all_buttons()

		focus_level = value

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
	if (transition_type == TransitionType.FROM_GAME):
		lets_sweep_button.get_parent().remove_child(lets_sweep_button)
		lets_sweep_button.queue_free()
		button_selection_handler.call_deferred("_retrieve_buttons")

	button_selection_handler.on_button_pressed.connect(_on_button_pressed)
	
	category_select_button_handler.on_button_pressed.connect(_on_category_button_pressed)

	focus_level = 1

	for button in button_selection_handler.buttons:
		button.on_mouse_selection.connect(_on_navigation_button_mouse_selection)
		button.on_mouse_deselection.connect(_on_navigation_button_mouse_deselection)

func _on_navigation_button_mouse_selection(button : UIButton):
	category_select_button_handler._select_button(-999)

	if (is_in_category):
		current_category.button_selection_handler._select_button(-999)

	button_selection_handler._enable_all_buttons()
	button_selection_handler._select_button(button_selection_handler.buttons.find(button))

func _on_navigation_button_mouse_deselection(button : UIButton):
	button_selection_handler._disable_all_buttons()
	button_selection_handler._select_button(-999)
	focus_level = 1

	reset_entry_selection = true

func _process(delta):
	if (Input.is_action_just_pressed("gamepad_dpad_up") or Input.is_action_just_pressed("player_move_forward") or Input.is_action_just_pressed("gamepad_dpad_down") or Input.is_action_just_pressed("player_move_backwards")):
		focus_level += 1

		if (focus_level == 0):
			button_selection_handler._next_button()
		else:
			category_select_button_handler._next_button()

	if (is_in_category and focus_level == 1 and reset_entry_selection):
		if (Input.is_action_just_pressed("gamepad_dpad_up") or Input.is_action_just_pressed("player_move_forward") or Input.is_action_just_pressed("gamepad_dpad_down") or Input.is_action_just_pressed("player_move_backwards") 
		or Input.is_action_just_pressed("gamepad_dpad_left") or Input.is_action_just_pressed("player_move_left") or Input.is_action_just_pressed("gamepad_dpad_right") or Input.is_action_just_pressed("player_move_right")):
			current_category.button_selection_handler._select_first_button()
			reset_entry_selection = false

	if (Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("pause")):
		_on_back_button_pressed()

func _on_button_pressed(button : UIButton):
	match (button):
		back_button:
			_on_back_button_pressed()
		lets_sweep_button:
			if (transition_type == TransitionType.FROM_TITLE):
				SceneTransitionHandler.instance._load_game_scene(Main.instance.current_stashed_level)

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

	on_shop_closed.emit()

	if (transition_type == TransitionType.FROM_TITLE):
		SceneTransitionHandler.instance._load_stage_select_scene()