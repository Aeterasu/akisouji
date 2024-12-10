class_name Main extends Node

@export var loading_screen : Control = null

@export var stage_start_audio : AudioStreamPlayer = null

@export var music_manager : MusicManager = null

var current_stashed_level : PackedScene = null

static var instance = null

func _ready():
	instance = self

	_update_volume()

	SceneTransitionHandler.instance._load_title_screen_scene()

	loading_screen.modulate = Color(0.0, 0.0, 0.0, 0.0)

	SaveManager._load()

	music_manager.player.play()
	(music_manager.player.sound_effect as MultiSoundEffect).mode = MultiSoundEffect.Mode.SHUFFLE

func _process(delta):
	_update_volume()

func _update_volume():
	AudioServer.set_bus_volume_db(0, linear_to_db(GlobalSettings.master_volume))
	AudioServer.set_bus_volume_db(1, linear_to_db(GlobalSettings.sfx_volume))
	AudioServer.set_bus_volume_db(2, linear_to_db(GlobalSettings.ambience_volume))
	AudioServer.set_bus_volume_db(3, linear_to_db(GlobalSettings.music_volume))

func _take_screenshot() -> void:
	var capture = get_viewport().get_texture().get_image()
	var _time = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "user://Screenshot-{0}.png".format({"0":_time})
	capture.save_png(filename)