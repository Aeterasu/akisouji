class_name UIUpscaler extends Node

var parent : Control = null

func _ready() -> void:
    parent = get_parent()

func _process(delta):
    if (parent):
        _upscale()

func _upscale() -> void:
    var y_coeff : float = parent.get_viewport_rect().size.y / parent.size.y
    parent.size = Vector2(parent.get_viewport_rect().size.x / y_coeff, 720.0)
    parent.scale = Vector2.ONE * y_coeff