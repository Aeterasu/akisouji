class_name LeafNoiseSprite extends Sprite2D

var viewport_position : Vector2 = Vector2()

func _process(delta):
    queue_redraw()

func _draw():
    draw_rect(Rect2(viewport_position, Vector2.ONE), Color(0.0, 0.0, 0.0))