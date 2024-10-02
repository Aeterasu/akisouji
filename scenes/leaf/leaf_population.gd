extends Node

@export var leaves_per_pixel : int = 4

@export var target_multimesh_instance : MultiMeshInstance3D = null
@export var target_sub_viewport : SubViewport = null

@export var leaf_cleaning_handler : LeafCleaningHandler = null

var multimesh : MultiMesh = null

var viewport_image_size = Vector2i()
var white_pixels : Array[Vector2]

var pixel_offset : int = 0

var is_populated : bool = false

var current_cleaning_position = Vector2i()

var leaf_data_array : Array[LeafInstanceData] = []

func _ready():
	leaf_cleaning_handler.on_origin_position_update.connect(_on_clean_origin_position_updated)

func _physics_process(delta):
	if (Input.is_action_just_pressed("1")):
		_populate_multimesh()

	if (Input.is_action_just_pressed("2")):
		_translate_multimesh()

func _populate_multimesh():
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
			if (image_data.get_pixel(j, i).r > 0.1):
				white_pixel_count += 1
				white_pixels.append(Vector2(j, i))

	multimesh.instance_count = white_pixel_count * leaves_per_pixel

func _translate_multimesh():
	print(multimesh.instance_count)

	var offset : int = 0

	for u in range(len(white_pixels)):
		var leaf_data = LeafInstanceData.create(Vector2i(floor(white_pixels[u].x), floor(white_pixels[u].y)))
		leaf_data_array.append(leaf_data)
		for v in (range(leaves_per_pixel)):

			var origin = Vector3(white_pixels[u].x - pixel_offset + (randf() - 0.5) * 2, 1, white_pixels[u].y - pixel_offset + (randf() - 0.5) * 2)
			var transform = Transform3D()
			transform = transform.rotated(Vector3.UP, randf() * PI * 2)
			transform = transform.translated(origin)
			multimesh.set_instance_transform(offset, transform)

			leaf_data.indexes.append(offset)

			offset += 1
	
	is_populated = true

func _on_clean_origin_position_updated(global_position : Vector3) -> void:
	var viewport_position = Vector2i(int(global_position.x + pixel_offset), int(global_position.z + pixel_offset))

	if (current_cleaning_position == viewport_position):
		return

	current_cleaning_position = viewport_position
	_clean_on_viewport_position(viewport_position)
	_clean_on_viewport_position(viewport_position + Vector2i.LEFT)
	_clean_on_viewport_position(viewport_position + Vector2i.RIGHT)
	_clean_on_viewport_position(viewport_position + Vector2i.UP)
	_clean_on_viewport_position(viewport_position + Vector2i.DOWN)

func _clean_on_viewport_position(viewport_position : Vector2i) -> void:
	if (!is_populated):
		return

	var transform = Transform3D()
	transform.origin = Vector3(999, 999, 999)

	for leaf_instance_data in leaf_data_array:
		if (leaf_instance_data.viewport_position == viewport_position):
			for i in leaf_instance_data.indexes:
				multimesh.set_instance_transform(i, transform)
			return