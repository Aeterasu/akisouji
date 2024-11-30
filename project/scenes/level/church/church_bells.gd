extends Node

@export var rate : float = 120.0
@export var audio : AudioStreamPlayer3D = null

var ticks : float = 0.0

func _physics_process(delta):
	ticks += delta

	if (!audio.playing and ticks >= rate):
		ticks = 0.0
		audio.play()