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

func _hide_ui_for_time(duration : float = 0.1) -> void:
	visible = false

	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(func(): visible = true)
	timer.call_deferred("start")