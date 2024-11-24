extends TextureRect

@export var speed : float = 1.0

func _process(delta):
	rotation_degrees += speed * delta