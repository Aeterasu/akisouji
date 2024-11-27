class_name StageSelect extends Control

@export var button_selection_handler : ButtonSelectionHandler = null
@export var back_button : UIButton = null
@export var proceed_button : UIButton = null

@export var navigation_button_selection_handler : ButtonSelectionHandler = null
@export var stages_container : StageSelectContainer = null
@export var right_button : UIButton = null
@export var left_button : UIButton = null
@export var stage_button : UIButton = null

@export var stage_select_mouse_area : UIButton = null

@export var edge_size : float = 360.0
@export var jump_size : float = 652.0

@export var scroll_lerp_weight : float = 4.0

@export var stage_name_label : Label = null
@export var stage_description_label : Label = null

@export var stage_background_origin : Control = null

@export var blackout : ColorRect = null

var current_selected_stage_id : int = 0
var stage_amount : int = 0

var target_scroll : float = 0.0
var current_scroll : float = 0.0

var stage_background_list : Array[TextureRect]

var focus_level : int = 0:
	set(value):
		if (value > 1):
			value = 0

		if (value == 0):
			button_selection_handler._enable_all_buttons()
			navigation_button_selection_handler._disable_all_buttons()

			for node in stages_container.container.get_children():
				(node as StageButton)._deselect()	

		elif (value > 0):
			button_selection_handler._disable_all_buttons()
			navigation_button_selection_handler._enable_all_buttons()

		focus_level = value

func _ready():
	button_selection_handler.on_button_pressed.connect(_on_button_pressed)

	navigation_button_selection_handler.on_button_pressed.connect(_on_navigation_button_pressed)
	navigation_button_selection_handler.on_button_selected.connect(_on_navigation_button_selected)

	target_scroll = edge_size
	current_scroll = edge_size

	focus_level = 1

	for button in button_selection_handler.buttons:
		button.on_mouse_selection.connect(_on_button_mouse_selection)
		button.on_mouse_deselection.connect(_on_button_mouse_deselection)

	stage_amount = stages_container.container.get_child_count()

	stage_background_list.resize(stage_amount)

	for i in stage_amount:
		stage_background_list[i] = stage_background_origin.get_child(i) as TextureRect
		stage_background_list[i].modulate = Color(1.0, 1.0, 1.0, 0.0)

	stage_background_list[0].modulate = Color(1.0, 1.0, 1.0, 1.0)

	blackout.modulate = Color(1.0, 1.0, 1.0, 1.0)

	var tween = create_tween()
	tween.tween_property(blackout, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.3)

	await get_tree().create_timer(0.05).timeout

	_reset_scroll()

func _on_button_mouse_selection(button : UIButton):
	navigation_button_selection_handler._select_button(-999)

	button_selection_handler._enable_all_buttons()
	button_selection_handler._select_button(button_selection_handler.buttons.find(button))

func _on_button_mouse_deselection(button : UIButton):
	button_selection_handler._disable_all_buttons()
	button_selection_handler._select_button(-999)
	focus_level = 1

func _process(delta):
	if (Input.is_action_just_pressed("gamepad_dpad_up") or Input.is_action_just_pressed("player_move_forward") or Input.is_action_just_pressed("gamepad_dpad_down") or Input.is_action_just_pressed("player_move_backwards")):
		focus_level += 1

		if (focus_level == 0):
			button_selection_handler._next_button()
		else:
			if (navigation_button_selection_handler.previous_button_id > -999):
				navigation_button_selection_handler.current_selection_id = navigation_button_selection_handler.previous_button_id
				navigation_button_selection_handler._update_button()
			else:
				navigation_button_selection_handler.current_selection_id = 1
				navigation_button_selection_handler._update_button()

	var s = stages_container.container.get_child(current_selected_stage_id) as StageButton

	_update_scroll(delta)

	stage_name_label.text = tr(s.name_key)
	stage_description_label.text = tr(s.description_key)
	
	for i in range(stage_amount):
		if (i == current_selected_stage_id):
			stage_background_list[i].modulate = stage_background_list[i].modulate.lerp(Color(1.0, 1.0, 1.0, 1.0), 2.0 * delta)
		else:
			stage_background_list[i].modulate = stage_background_list[i].modulate.lerp(Color(1.0, 1.0, 1.0, 0.0), 2.0 * delta)

	if (Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("menu_cancel")):
		_on_back_button_pressed()

func _update_scroll(delta) -> void:
	target_scroll = -(stages_container.container.get_child(current_selected_stage_id) as Control).position.x + ((size.x - 1280.0) * 0.5)
	current_scroll = lerp(current_scroll, target_scroll, scroll_lerp_weight * delta)
	stages_container.position.x = current_scroll

func _reset_scroll() -> void:
	target_scroll = -(stages_container.container.get_child(current_selected_stage_id) as Control).position.x + ((size.x - 1280.0) * 0.5)
	current_scroll = target_scroll
	stages_container.position.x = current_scroll

func _on_button_pressed(button : UIButton):
	match (button):
		back_button:
			_on_back_button_pressed()
		proceed_button:
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(blackout, "modulate", Color(0.0, 0.0, 0.0, 1.0), 0.2)
			tween.tween_callback(SceneTransitionHandler.instance._load_shop_scene).set_delay(0.2)

func _on_back_button_pressed():
	var tween = create_tween()
	tween.tween_property(blackout, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	tween.tween_callback(SceneTransitionHandler.instance._load_title_screen_scene).set_delay(0.2)

func _on_navigation_button_selected():
	if (navigation_button_selection_handler.current_selection_id == 1):
		for node in stages_container.container.get_children():
			if (node.get_index() == current_selected_stage_id):
				(node as StageButton)._select()
			else:
				(node as StageButton)._deselect()
	else:
		for node in stages_container.container.get_children():
			(node as StageButton)._deselect()		

func _on_navigation_button_pressed(button : UIButton):
	match (button):
		right_button:
			current_selected_stage_id = min(current_selected_stage_id + 1, stage_amount - 1)
		left_button:
			current_selected_stage_id = max(current_selected_stage_id - 1, 0)
		stage_button:
			Main.instance.current_stashed_level = (stages_container.container.get_child(current_selected_stage_id) as StageButton).stage_scene
			SceneTransitionHandler.instance._load_game_scene(Main.instance.current_stashed_level)