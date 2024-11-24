class_name LeafAudioHandler extends Node

@export var audio_player : AudioStreamPlayer3D = null
@export var cooldown : float = 0.2

var timer : Timer = Timer.new()

var allow_playing : bool = true

func _ready():
	add_child(timer)
	timer.wait_time = cooldown
	timer.timeout.connect(_on_timeout)

func _physics_process(delta):
	timer.wait_time = cooldown

func _on_timeout():
	allow_playing = true

func _on_leaves_cleaned(amount : int, scale : float = 1.0) -> void:
	if (!allow_playing):
		return

	if (amount <= 0):
		return

	amount = clamp(amount / 3, 1, 18)

	var node = audio_player.duplicate() as AudioStreamPlayer3D
	Game.game_instance.add_child(node)
	node.global_position = Game.game_instance.last_cleaning_position
	node.call_deferred("play", 0.0)

	allow_playing = false
	timer.start()