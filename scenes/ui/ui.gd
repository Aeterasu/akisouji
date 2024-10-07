class_name UI extends Control

@export var progress : UIProgress = null

static var ui_instance : UI

func _ready():
	if (ui_instance):
		self.queue_free()
	else:
		ui_instance = self

static func _get_ui() -> UI:
	return ui_instance

func _process(delta):
	_upscale()

func _upscale():
	var y_coeff : float = get_viewport_rect().size.y / size.y
	size = Vector2(get_viewport_rect().size.x / y_coeff, 720.0)
	scale = Vector2.ONE * y_coeff