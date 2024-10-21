extends Label

func _process(delta: float) -> void:
	visible = GlobalSettings.show_fps_counter

	set_text(str(Engine.get_frames_per_second()) + " FPS")