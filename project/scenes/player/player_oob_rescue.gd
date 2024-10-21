extends Node

@export var player : Player = null
@export var trouble_threshold : float = 3.0

var trouble_counter : float = 0.0

func _physics_process(delta) -> void:
	if (!player.is_on_floor()):
		trouble_counter += delta

		if (trouble_counter >= trouble_threshold):
			player.global_transform = player.respawn_transform
			trouble_counter = 0.0

			Output.print("Player out of bound, rescuing...")
	else:
		trouble_counter = 0.0