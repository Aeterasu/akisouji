class_name ButtonSelectionHandler extends Node

@export var enabled : bool = true

@export var horizontal : bool = false
@export var buttons_origin : Control = null

var current_button : UIButton = null
var current_selection_id : int = -999
var buttons : Array[UIButton] = []

signal on_button_pressed
signal on_button_selected

func _ready():
	if (buttons_origin):
		for node in buttons_origin.get_children():
			if (node is UIButton):
				buttons.append(node)
				node._deselect()
				node.on_mouse_selection.connect(_on_button_mouse_selection)
				node.on_mouse_deselection.connect(_on_button_mouse_deselection)

	if (!enabled):
		_disable_all_buttons()

func _process(delta):
	if (!enabled):
		current_selection_id = -999
		_update_button()
		return

	var next_key : String = ""
	var previous_key : String = ""

	var next_gamepad : String = ""
	var previous_gamepad : String = ""

	if horizontal:
		next_key = "player_move_left"
		previous_key = "player_move_right"
		next_gamepad = "gamepad_dpad_left"
		previous_gamepad = "gamepad_dpad_right"
	else:
		next_key = "player_move_backwards"
		previous_key = "player_move_forward"
		next_gamepad = "gamepad_dpad_down"
		previous_gamepad = "gamepad_dpad_up"

	if (Input.is_action_just_pressed(previous_key) or Input.is_action_just_pressed(previous_gamepad)):
		_previous_button()
	
	if (Input.is_action_just_pressed(next_key) or Input.is_action_just_pressed(next_gamepad)):
		_next_button()
		
	if (Input.is_action_just_pressed("menu_confirm") && current_button):
		var sfx = current_button.audio_accent_2.duplicate() as AudioStreamPlayer
		get_tree().root.add_child(sfx)
		SfxDeconflicter.call_deferred("play", sfx)
		sfx.finished.connect(sfx.queue_free)

		on_button_pressed.emit(current_button)

func _next_button():
	if (current_selection_id <= -999):
		current_selection_id = 0
		current_button = buttons[0]
		_update_button()
		return

	current_selection_id += 1

	if (current_selection_id > len(buttons) - 1):
		current_selection_id = 0

	_update_button()

func _previous_button():
	if (current_selection_id <= -999):
		current_selection_id = 0
		current_button = buttons[0]
		_update_button()
		return

	current_selection_id -= 1

	if (current_selection_id < 0):
		current_selection_id = len(buttons) - 1

	_update_button()

func _update_button():
	if (current_button):
		current_button._deselect()

	if (current_selection_id > -999):
		current_button = buttons[current_selection_id]
		current_button._select()
		on_button_selected.emit()
		return
	else:
		current_button = null
		current_selection_id = -999

func _on_button_mouse_selection(button : UIButton):
	current_selection_id = buttons.find(button)
	_update_button()

func _on_button_mouse_deselection(button : UIButton):
	current_selection_id = -999
	_update_button()

func _disable_all_buttons():
	enabled = false

	for button in buttons:
		button._disable()

func _enable_all_buttons():
	enabled = true

	for button in buttons:
		button._enable()