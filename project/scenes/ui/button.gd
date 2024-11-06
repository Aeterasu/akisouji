class_name UIButton extends Control

@export var mouse_area : Control = null

@export var text_key : String = ""
@export var label : Label = null
@export var custom_font_size : int = -1

@export var audio_accent_1 : AudioStreamPlayer = null
@export var audio_accent_2 : AudioStreamPlayer = null

var is_selected : bool = false

var tween : Tween = null

var is_disabled : bool = false

var is_blocked : bool = false

signal on_mouse_selection
signal on_mouse_deselection

signal on_selected
signal on_deselected

func _ready():
	mouse_area.mouse_entered.connect(func(): on_mouse_selection.emit(self))
	mouse_area.mouse_exited.connect(func(): on_mouse_deselection.emit(self))

	if (label and custom_font_size > -1):
		label.set("theme_override_font_sizes/font_size", custom_font_size)

func _process(delta):
	if (label):
		label.text = tr(text_key)

func _select():
	if (is_disabled):
		return

	if (is_selected):
		return

	SfxDeconflicter.play(audio_accent_1)

	is_selected = true

	on_selected.emit(self)
	
func _deselect():
	if (!is_selected):
		return

	is_selected = false

	on_deselected.emit(self)

func _disable():
	is_disabled = true
	_deselect()

func _enable():
	if (is_blocked):
		return

	is_disabled = false