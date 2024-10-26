class_name Main extends Node

@export var title_screen_scene : PackedScene = null

static var instance = null

func _ready():
	instance = self

	GlobalSettings.locale = GlobalSettings.locale
	TranslationServer.set_locale(GlobalSettings.locale)

	Output.print(OS.get_data_dir())

	SceneTransitionHandler.instance._load_scene(title_screen_scene.resource_path)

	GlobalSettings.fullscreen = GlobalSettings.fullscreen

func _process(delta):
	AudioServer.set_bus_volume_db(0, linear_to_db(GlobalSettings.master_volume))
	AudioServer.set_bus_volume_db(1, linear_to_db(GlobalSettings.sfx_volume))
	AudioServer.set_bus_volume_db(2, linear_to_db(GlobalSettings.ambience_volume))
	AudioServer.set_bus_volume_db(3, linear_to_db(GlobalSettings.music_volume))

func _take_screenshot() -> void:
	var capture = get_viewport().get_texture().get_image()
	var _time = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "user://Screenshot-{0}.png".format({"0":_time})
	capture.save_png(filename) 