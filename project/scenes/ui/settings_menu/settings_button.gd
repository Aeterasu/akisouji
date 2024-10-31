class_name SettingsButton extends UIButton

@export var highlight : Control = null

@export var selected_alpha : float = 0.8
@export var default_alpha : float = 0.2

@export var setting_label : Label = null

@export var setting_toggle : SettingsFunction = null

@export var setting_slider : SettingsSlider = null

func _ready():
	mouse_area.mouse_entered.connect(func(): on_mouse_selection.emit(self))
	mouse_area.mouse_exited.connect(func(): on_mouse_deselection.emit(self))

	highlight.modulate = Color(1.0, 1.0, 1.0, default_alpha)

	if (custom_font_size > -1):
		label.set("theme_override_font_sizes/font_size", custom_font_size)

func _process(delta):
	label.text = tr(text_key)
	
	if (setting_toggle):
		setting_label.text = setting_toggle.setting_text

	if (setting_slider):
		setting_label.text = setting_slider.setting_text

func _select():
	if (is_disabled):
		return

	if (is_selected):
		return

	if (tween):
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(highlight, "modulate", Color(1.0, 1.0, 1.0, selected_alpha), 0.2)

	SfxDeconflicter.play(audio_accent_1)

	is_selected = true
	
func _deselect():
	if (!is_selected):
		return

	if (tween):
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(highlight, "modulate", Color(1.0, 1.0, 1.0, default_alpha), 0.2)	

	is_selected = false

func _disable():
	is_disabled = true
	_deselect()

func _enable():
	is_disabled = false
