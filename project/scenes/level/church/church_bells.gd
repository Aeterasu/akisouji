extends Node

@export var rate : float = 120.0
@export var first_time : float = 60.0
@export var audio : AudioStreamPlayer3D = null

var ticks : float = 0.0

func _ready():
	ticks = first_time

func _physics_process(delta):
	ticks -= delta

	if (!audio.playing and ticks <= 0.0):
		ticks = rate
		audio.play()