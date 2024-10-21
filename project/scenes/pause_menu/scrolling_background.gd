extends TextureRect

@export var speed : float = 0.25

func _process(delta):
	position += Vector2.RIGHT * speed

	if (position >= Vector2.RIGHT * 0.0):
		position = Vector2(-1280.0, 0.0)