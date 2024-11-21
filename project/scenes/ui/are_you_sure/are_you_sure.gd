class_name AreYouSure extends Control

@export var button_selection_handler : ButtonSelectionHandler = null
@export var yes_button : UIButton = null
@export var no_button : UIButton = null

signal on_no_pressed
signal on_yes_pressed

func _ready():
	modulate = Color(0.0, 0.0, 0.0, 0.0)

	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)

	button_selection_handler.on_button_pressed.connect(_on_button_pressed)

func _process(delta):
	if (Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("menu_cancel")):
		_on_no_pressed()

func _on_button_pressed(button : UIButton):
	button_selection_handler._disable_all_buttons()

	match (button):
		yes_button:
			on_yes_pressed.emit()
			return
		no_button:
			_on_no_pressed()
			return

func _on_no_pressed():
	on_no_pressed.emit()
	
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.2)
	tween.tween_callback(queue_free).set_delay(0.2)