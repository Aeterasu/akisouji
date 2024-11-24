class_name LoadingScreen extends Control

func _on_timeout():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.3).set_delay(0.3)
	tween.tween_callback(queue_free).set_delay(1.0)
	tween.play()