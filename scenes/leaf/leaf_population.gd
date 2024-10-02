extends Node

@export var leaves_per_pixel : int = 4

@export var target_multimesh_instance : MultiMeshInstance3D = null
@export var target_sub_viewport : SubViewport = null

var multimesh : MultiMesh = null

var viewport_image_size = Vector2i()
var white_pixels : Array[Vector2]

func _physics_process(delta):
	if (Input.is_action_just_pressed("1")):
		populate_multimesh()

	if (Input.is_action_just_pressed("2")):
		translate_multimesh()

func populate_multimesh():
	#get our multimesh
	multimesh = target_multimesh_instance.multimesh

	#get all white pixels in our noise texture
	# 0 - no leaf, 1 - leaf
	var viewport_texture = target_sub_viewport.get_texture()
	var image_data = viewport_texture.get_image()

	viewport_image_size = image_data.get_size()

	var white_pixel_count : int = 0

	for i in viewport_image_size.x:
		for j in viewport_image_size.y:
			if (image_data.get_pixel(i, j).r > 0.1):
				white_pixel_count += 1
				white_pixels.append(Vector2(i, j))

	multimesh.instance_count = white_pixel_count * leaves_per_pixel

func translate_multimesh():
	print(multimesh.instance_count)

	var offset : int = 0

	for u in range(len(white_pixels)):
		for v in (range(leaves_per_pixel)):
			var transform = Transform3D(Basis(), Vector3(white_pixels[u].x - 16 + (randf() - 0.5) * 2, 1, white_pixels[u].y - 16 + (randf() - 0.5) * 2))
			multimesh.set_instance_transform(offset, transform)
			offset += 1