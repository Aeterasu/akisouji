extends Node

@export var player : SoundEffectPlayer = null

func _ready():
	player.finished.connect(player.play)