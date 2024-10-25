extends Node

@export var viewport : SubViewport = null
@export_range(0, 5) var update_rate : float = 0.5

var current_progress : float = 0.0

var timer : Timer = Timer.new()

func _ready():
	timer.wait_time = update_rate
	add_child(timer)
	timer.timeout.connect(_on_update)
	timer.start()

func _on_update():
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	var image = viewport.get_texture().get_image()

	current_progress = 0.0

	for i in image.get_size().x:
		for j in image.get_size().y:
			current_progress += 1.0 - (image.get_pixel(i, j).v)

	print(current_progress)