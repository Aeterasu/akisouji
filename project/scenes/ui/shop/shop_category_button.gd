class_name ShopCategoryButton extends UIButton

@export var animation_origin : Control = null

var default_position : Vector2 = Vector2()

func _ready():
	mouse_area.mouse_entered.connect(func(): on_mouse_selection.emit(self))
	mouse_area.mouse_exited.connect(func(): on_mouse_deselection.emit(self))

	if (custom_font_size > -1):
		label.set("theme_override_font_sizes/font_size", custom_font_size)

	default_position = position

func _select():
	if (is_disabled):
		return

	if (is_selected):
		return

	if (tween):
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(animation_origin, "position", default_position + Vector2.UP * 32, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)	

	#SfxDeconflicter.play(audio_accent_1)

	is_selected = true
	
func _deselect():
	if (!is_selected):
		return

	if (tween):
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(animation_origin, "position", default_position, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	is_selected = false