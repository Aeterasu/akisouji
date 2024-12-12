class_name MusicManager extends Node

@export var gameplay_music : AudioStreamPlayer = null
@export var menu_music : AudioStreamPlayer = null

var gameplay_volume : float = 1.0
var menu_volume : float = 1.0

var default_gameplay_volume : float = 0.0
var default_menu_volume : float = 0.0

var gameplay_first_time : bool = true

var tween : Tween = null

var currently_playing : CurrentlyPlaying = CurrentlyPlaying.MENU:
	set(value):
		if (value == currently_playing):
			return

		if (value == CurrentlyPlaying.MENU):
			tween = create_tween()
			tween.tween_property(self, "gameplay_volume", 0.0, 0.3)
			tween.tween_property(self, "menu_volume", default_menu_volume, 0.5)
			tween.tween_callback(_stop_gameplay_music).set_delay(0.3)

			if (!menu_music.playing):
				menu_music.play()

		elif (value == CurrentlyPlaying.GAMEPLAY):
			tween = create_tween()
			tween.tween_property(self, "menu_volume", 0.0, 0.2)
			tween.tween_callback(menu_music.stop).set_delay(0.2)

			gameplay_volume = default_gameplay_volume

			if (!gameplay_music.playing):
				tween.tween_callback(_gameplay_music_play).set_delay(0.4)

		currently_playing = value

enum CurrentlyPlaying
{
	MENU,
	GAMEPLAY
}

func _stop_gameplay_music() -> void:
	if (currently_playing != CurrentlyPlaying.GAMEPLAY): 
		gameplay_music.stop()

func _ready():
	default_gameplay_volume = db_to_linear(gameplay_music.volume_db)
	default_menu_volume = db_to_linear(menu_music.volume_db)

	pass

func _process(delta):
	gameplay_music.volume_db = linear_to_db(gameplay_volume)
	menu_music.volume_db = linear_to_db(menu_volume)

func _gameplay_music_play() -> void:
	gameplay_music.play()

	if (gameplay_first_time):
		gameplay_first_time = false

		await get_tree().create_timer(0.2).timeout
		(gameplay_music.stream as AudioStreamPlaylist).set_deferred("shuffle", true)