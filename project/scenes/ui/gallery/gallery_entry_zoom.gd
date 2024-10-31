class_name GalleryEntryZoom extends Control

@export var entry_origin : Control = null

var is_displayed = false

func _ready():
	entry_origin.scale = Vector2.ONE * 0.5
	modulate = Color(0.0, 0.0, 0.0, 0.0)

	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

func _display(texture : ImageTexture):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(entry_origin, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP

	entry_origin.get_child(0).texture = texture

	is_displayed = true

func _undisplay():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(entry_origin, "scale", Vector2.ONE * 0.5, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.3)

	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

	is_displayed = false