class_name ButtonSelectionHandler extends Node

@export var buttons_origin : Node = null

var current_button : PaperButton = null
var current_selection_id : int = 0
var buttons : Array[PaperButton] = []

signal on_button_pressed

func _ready():
	if (buttons_origin):
		for node in buttons_origin.get_children():
			if (node is PaperButton):
				buttons.append(node)
				node._deselect()
				node.on_mouse_selection.connect(_on_button_mouse_selection)
				node.on_mouse_deselection.connect(_on_button_mouse_deselection)

func _process(delta):
	if (Input.is_action_just_pressed("player_move_forward")):
		_previous_button()
	
	if (Input.is_action_just_pressed("player_move_backwards")):
		_next_button()

	if (Input.is_action_just_pressed("menu_confirm")):
		on_button_pressed.emit(current_button)

func _next_button():
	if (!current_button):
		current_button = buttons[0]
		_update_button()
		return

	current_selection_id += 1

	if (current_selection_id > len(buttons) - 1):
		current_selection_id = 0

	_update_button()

func _previous_button():
	if (!current_button):
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

	current_button = buttons[current_selection_id]

	current_button._select()

func _on_button_mouse_selection(button : PaperButton):
	current_selection_id = buttons.find(button)
	_update_button()

func _on_button_mouse_deselection(button : PaperButton):
	pass