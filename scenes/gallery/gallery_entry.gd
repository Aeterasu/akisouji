extends TextureRect

@export var highlight : TextureRect = null
@export var magnifying_glass : TextureRect = null
@export var audio_selection_accent : AudioStreamPlayer = null

var is_selected : bool = false

var tween : Tween = null

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	highlight.modulate = Color(0.0, 0.0, 0.0)
	magnifying_glass.modulate = Color(0.0, 0.0, 0.0, 0.0)

func _on_mouse_entered():
	if (tween):
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(highlight, "modulate", Color(1.0, 1.0, 1.0), 0.2)
	tween.tween_property(magnifying_glass, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

	audio_selection_accent.play()

func _on_mouse_exited():
	if (tween):
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(highlight, "modulate", Color(0.0, 0.0, 0.0), 0.2)
	tween.tween_property(magnifying_glass, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.2)