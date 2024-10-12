extends Node

@export var player : Player = null
@export var trouble_threshold : float = 3.0

var trouble_counter : float = 0.0

var rescue_position : Vector3 = Vector3()

func _ready() -> void:
	rescue_position = player.global_position

func _physics_process(delta) -> void:
	if (!player.is_on_floor()):
		trouble_counter += delta

		if (trouble_counter >= trouble_threshold):
			player.global_position = rescue_position
			trouble_counter = 0.0