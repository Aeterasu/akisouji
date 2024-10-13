class_name Main extends Node

static var instance = null

func _ready():
	instance = self

	SceneTransitionHandler.instance._load_scene("res://scenes/title_screen/title_screen.tscn")

func _process(delta) -> void:
	if (Input.is_action_just_pressed("ui_cancel")):
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if (Input.is_action_just_pressed("screenshot")):
		UI.ui_instance.call_deferred("_hide_ui_for_time", 0.2)
		await get_tree().create_timer(0.1).timeout
		self.call_deferred("_take_screenshot")

func _take_screenshot() -> void:
	var capture = get_viewport().get_texture().get_image()
	var _time = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "user://Screenshot-{0}.png".format({"0":_time})
	capture.save_png(filename) 