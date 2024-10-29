extends CSGBox3D

@export var factor : float = 0.9

func _process(delta):
	transform = transform.scaled(Vector3.ONE - (Vector3.ONE * factor * delta))