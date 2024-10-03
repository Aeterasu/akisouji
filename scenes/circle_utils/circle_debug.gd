extends Node2D

@export var radius : int = 2

var points : Array[Vector2i] = []

func _ready():
	points = CircleUtils.get_circle_vector_array(Vector2i.ONE * 32, radius)
	
func _process(delta):
	queue_redraw()

func _draw():
	for point in points:
		draw_rect(Rect2(point, Vector2.ONE), Color(1.0, 1.0, 1.0))