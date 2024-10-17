class_name PaperButton extends Control

@export var mouse_area : Control = null

@export var text_key : String = ""
@export var label : Label = null

@export var animation_origin : Control = null
@export var target_selected_position : Vector2 = Vector2(0, 0)
@export var target_deselected_position : Vector2 = Vector2(-96, 0)

@export var selected_gradient : TextureRect = null
@export var deselected_gradient : TextureRect = null

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

signal on_mouse_selection
signal on_mouse_deselection

var tween : Tween = null

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

func _process(delta):
	gradient_1.set_color(0, current_color_1_1)
	gradient_1.set_color(1, current_color_1_2)

	gradient_2.set_color(0, current_color_2_1)
	gradient_2.set_color(1, current_color_2_2)

	label.text = tr(text_key)

func _select():
	if (tween):
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(animation_origin, "position", target_selected_position, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "current_color_1_1", gradient_1_color_1, 0.1)
	tween.tween_property(self, "current_color_1_2", gradient_1_color_2, 0.1)

	tween.tween_property(self, "current_color_2_1", Color.WHITE, 0.2)
	tween.tween_property(self, "current_color_2_2", Color.WHITE, 0.2)
	
func _deselect():
	if (tween):
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(animation_origin, "position", target_deselected_position, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "current_color_1_1", Color.WHITE, 0.2)
	tween.tween_property(self, "current_color_1_2", Color.WHITE, 0.2)

	tween.tween_property(self, "current_color_2_1", gradient_2_color_1, 0.1)
	tween.tween_property(self, "current_color_2_2", gradient_2_color_2, 0.1)
