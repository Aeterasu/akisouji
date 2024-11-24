extends Control

@export var anim_duration : float = 1.0
@export var scale_offset : float = 0.1

var timer : Timer = Timer.new()

var toggle : bool = false

func _ready():
	timer.wait_time = anim_duration
	add_child(timer)

	timer.start()
	timer.timeout.connect(on_timeout)

func on_timeout() -> void:
	toggle = not toggle
	var s : Vector2 = Vector2.ONE

	if (toggle):
		s = Vector2.ONE + Vector2.ONE * scale_offset

	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", s, anim_duration * 0.95)