class_name MusicManager extends Node

@export var gameplay_music : AudioStreamPlayer = null
@export var menu_music : AudioStreamPlayer = null

var gameplay_volume : float = 1.0
var menu_volume : float = 1.0

var default_gameplay_volume : float = 0.0
var default_menu_volume : float = 0.0

var currently_playing : CurrentlyPlaying = CurrentlyPlaying.MENU:
	set(value):
		if (value == CurrentlyPlaying.MENU):
			var tween = create_tween()
			tween.tween_property(self, "gameplay_volume", 0.0, 0.5)
			tween.tween_property(self, "menu_volume", default_menu_volume, 0.5)
			tween.tween_callback(gameplay_music.stop).set_delay(0.5)

			if (!menu_music.playing):
				menu_music.play()

		elif (value == CurrentlyPlaying.GAMEPLAY):
			var tween = create_tween()
			tween.tween_property(self, "menu_volume", 0.0, 0.2)
			tween.tween_callback(menu_music.stop).set_delay(0.2)

			gameplay_volume = default_gameplay_volume

			if (!gameplay_music.playing):
				tween.tween_callback(_first_time_gameplay_music_play).set_delay(0.4)
				(gameplay_music.stream as AudioStreamPlaylist).shuffle = true

enum CurrentlyPlaying
{
	MENU,
	GAMEPLAY
}

func _ready():
	default_gameplay_volume = db_to_linear(gameplay_music.volume_db)
	default_menu_volume = db_to_linear(menu_music.volume_db)

	pass

func _process(delta):
	gameplay_music.volume_db = linear_to_db(gameplay_volume)
	menu_music.volume_db = linear_to_db(menu_volume)

func _first_time_gameplay_music_play() -> void:
	gameplay_music.play()
	(gameplay_music.stream as AudioStreamPlaylist).shuffle = true