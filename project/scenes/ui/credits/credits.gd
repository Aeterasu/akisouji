class_name Credits extends Control

@export var font_size_1 : float = 24.0
@export var font_size_2 : float = 18.0

@export var font_color_1 : Color = Color(0.8, 0.8, 0.8, 1.0)
@export var font_color_2 : Color = Color(1.0, 1.0, 1.0, 1.0)

@export var splash : Control = null
@export var label : RichTextLabel = null

signal on_credits_closed

func _ready():
	splash.scale = Vector2.ONE * 0.75
	splash.modulate = Color(0.0, 0.0, 0.0, 0.0)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(splash, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(splash, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)

func _process(delta):
	if (Input.is_action_just_pressed("menu_confirm") or Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("menu_cancel")):
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(splash, "scale", Vector2.ONE * 0.5, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(splash, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.4)
		tween.tween_callback(on_credits_closed.emit).set_delay(0.1)
		tween.tween_callback(queue_free).set_delay(0.4)

	label.text = "[center]"

	label.text += "[color=" + str(font_color_1.to_html()) + "]"
	label.text += "[font_size=" + str(font_size_1) + "]" + tr("CREDITS_1") + "[/font_size]"
	label.text += "[/color]"

	label.text += "\n"
	label.text += "[color=" + str(font_color_2.to_html()) + "]"
	label.text += "[font_size=" + str(font_size_2) + "]" + tr("CREDITS_2") + "[/font_size]"
	label.text += "[/color]"
	label.text += "\n"

	label.text += "\n"
	label.text += "\n"

	label.text += "[color=" + str(font_color_1.to_html()) + "]"
	label.text += "[font_size=" + str(font_size_1) + "]" + tr("CREDITS_3") + "[/font_size]"
	label.text += "[/color]"
	label.text += "\n"
	label.text += "[color=" + str(font_color_2.to_html()) + "]"
	label.text += "[font_size=" + str(font_size_2) + "]" + tr("CREDITS_4") + "[/font_size]"
	label.text += "[/color]"
	label.text += "\n"

	label.text += "\n"
	label.text += "\n"

	label.text += "[color=" + str(font_color_1.to_html()) + "]"
	label.text += "[font_size=" + str(font_size_1) + "]" + tr("CREDITS_5") + "[/font_size]"
	label.text += "[/color]"

	label.text += "\n"
	label.text += "[color=" + str(font_color_2.to_html()) + "]"
	label.text += "[font_size=" + str(font_size_2) + "]" + tr("CREDITS_6") + "[/font_size]"
	label.text += "\n"
	label.text += "[font_size=" + str(font_size_2) + "]" + tr("CREDITS_2") + "[/font_size]"
	label.text += "[/color]"

	label.text += "[/center]"