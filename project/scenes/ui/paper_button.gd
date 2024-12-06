class_name PaperButton extends UIButton

@export var animation_type : AnimationType = AnimationType.DEFAULT
@export var animation_origin : Control = null
@export var target_selected_position : Vector2 = Vector2(0, 0)
@export var target_deselected_position : Vector2 = Vector2(-96, 0)

@export var selected_gradient : TextureRect = null
@export var deselected_gradient : TextureRect = null

@export var disable_click_accent : bool = false

var gradient_1 : Gradient = null
var gradient_1_color_1 : Color = Color(1.0, 1.0, 1.0, 1.0)
var gradient_1_color_2 : Color = Color(1.0, 1.0, 1.0, 1.0)

var current_color_1_1 : Color = Color(1.0, 1.0, 1.0, 1.0)
var current_color_1_2 : Color = Color(1.0, 1.0, 1.0, 1.0)

var gradient_2 : Gradient = null
var gradient_2_color_1 : Color = Color(1.0, 1.0, 1.0, 1.0)
var gradient_2_color_2 : Color = Color(1.0, 1.0, 1.0, 1.0)

var current_color_2_1 : Color = Color(1.0, 1.0, 1.0, 1.0)
var current_color_2_2 : Color = Color(1.0, 1.0, 1.0, 1.0)

enum AnimationType
{
	NONE,
	DEFAULT,
	DOUBLE_SIDED,
}

func _ready():
	selected_gradient.texture = selected_gradient.texture.duplicate()	
	gradient_1 = (selected_gradient.texture as GradientTexture2D).gradient.duplicate()
	gradient_1_color_1 = gradient_1.colors[0]
	gradient_1_color_2 = gradient_1.colors[1]

	deselected_gradient.texture = deselected_gradient.texture.duplicate()
	gradient_2 = (deselected_gradient.texture as GradientTexture2D).gradient.duplicate()
	gradient_2_color_1 = gradient_2.colors[0]
	gradient_2_color_2 = gradient_2.colors[1]

	(selected_gradient.texture as GradientTexture2D).gradient = gradient_1
	(deselected_gradient.texture as GradientTexture2D).gradient = gradient_2

	mouse_area.mouse_entered.connect(func(): on_mouse_selection.emit(self))
	mouse_area.mouse_exited.connect(func(): on_mouse_deselection.emit(self))

	if (label and custom_font_size > -1):
		label.set("theme_override_font_sizes/font_size", custom_font_size)
		#label.theme_override_font_sizes.outline_size = label.theme_override_font_sizes.outline_size

	if (animation_type == AnimationType.DEFAULT):
		animation_origin.position = target_deselected_position
	
	current_color_2_1 = gradient_2_color_1
	current_color_2_2 = gradient_2_color_2

func _process(delta):
	gradient_1.set_color(0, current_color_1_1)
	gradient_1.set_color(1, current_color_1_2)

	gradient_2.set_color(0, current_color_2_1)
	gradient_2.set_color(1, current_color_2_2)

	if (label):
		label.text = tr(text_key)

func _select():
	if (is_disabled):
		return

	if (is_selected):
		return

	if (tween):
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)

	if (animation_type == AnimationType.DEFAULT):
		tween.tween_property(animation_origin, "position", target_selected_position, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	elif (animation_type == AnimationType.DOUBLE_SIDED):
		tween.tween_property(animation_origin, "position", Vector2(500 - 48 / 2, 24) + Vector2.LEFT * 32, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(animation_origin, "size", Vector2(278 + 96, 42), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "current_color_1_1", gradient_1_color_1, 0.1)
	tween.tween_property(self, "current_color_1_2", gradient_1_color_2, 0.1)

	tween.tween_property(self, "current_color_2_1", Color.WHITE, 0.2)
	tween.tween_property(self, "current_color_2_2", Color.WHITE, 0.2)		

	SfxDeconflicter.play(audio_accent_1)

	is_selected = true

	on_selected.emit(self)
	
func _deselect():
	if (!is_selected):
		return

	if (tween):
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)

	if (animation_type == AnimationType.DEFAULT):	
		tween.tween_property(animation_origin, "position", target_deselected_position, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	elif (animation_type == AnimationType.DOUBLE_SIDED):
		tween.tween_property(animation_origin, "position", Vector2(500, 24), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(animation_origin, "size", Vector2(278, 42), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "current_color_1_1", Color.WHITE, 0.2)
	tween.tween_property(self, "current_color_1_2", Color.WHITE, 0.2)

	tween.tween_property(self, "current_color_2_1", gradient_2_color_1, 0.1)
	tween.tween_property(self, "current_color_2_2", gradient_2_color_2, 0.1)

	is_selected = false

	on_deselected.emit(self)

func _disable():
	is_disabled = true
	_deselect()

func _enable():
	is_disabled = false