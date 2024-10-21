extends TextureRect

@export var player : Player = null

@export var fps : float = 24.0

@export var target_color : Color = Color(1.0, 1.0, 1.0, 1.0)

var timer : Timer = Timer.new()

var current_texture_id = 0

func _ready():
	add_child(timer)
	timer.wait_time = 1.0 / fps
	timer.timeout.connect(_update_texture)
	timer.start()

func _process(delta):
	if (player.wish_sprint):
		modulate = modulate.lerp(target_color, 13 * delta)
	else:
		modulate = modulate.lerp(Color(0.0, 0.0, 0.0, 1.0), 8 * delta)

func _update_texture():
	current_texture_id += 1

	if (current_texture_id > 2):
		current_texture_id = 0

	var atlas = texture as AtlasTexture
	atlas.region.position.y = current_texture_id * 180