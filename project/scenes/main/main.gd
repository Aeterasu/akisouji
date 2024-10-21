class_name Main extends Node

static var instance = null

func _ready():
	instance = self

	TranslationServer.set_locale("en")

	Output.print(OS.get_data_dir())

	SceneTransitionHandler.instance._load_scene("res://scenes/title_screen/title_screen.tscn")

func _take_screenshot() -> void:
	var capture = get_viewport().get_texture().get_image()
	var _time = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "user://Screenshot-{0}.png".format({"0":_time})
	capture.save_png(filename) 