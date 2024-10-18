class_name Main extends Node

static var instance = null

func _ready():
	instance = self

	TranslationServer.set_locale("en")

	SceneTransitionHandler.instance._load_scene("res://scenes/title_screen/title_screen.tscn")
	#SceneTransitionHandler.instance._load_scene("res://scenes/game/game.tscn")

func _take_screenshot() -> void:
	#UI.ui_instance.call_deferred("_hide_ui_for_time", 0.2)
	#await get_tree().create_timer(0.1).timeout

	var capture = get_viewport().get_texture().get_image()
	var _time = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "user://Screenshot-{0}.png".format({"0":_time})
	capture.save_png(filename) 