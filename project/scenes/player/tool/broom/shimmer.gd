extends AudioStreamPlayer

@export var target_volume : float = 0.8
@export var play_shimmer : bool = false

@export var broom : Broom = null

var current_volume : float = 0.0

func _ready():
	volume_db = linear_to_db(current_volume)

func _process(delta):
	play_shimmer = broom.is_equipped

	if (play_shimmer):
		current_volume = lerp(current_volume, target_volume, 5.0 * delta)
	else:
		current_volume = lerp(current_volume, 0.0, 5.0 * delta)

	volume_db = linear_to_db(current_volume)