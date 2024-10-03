extends Node

@export var leaves_per_pixel : int = 4
@export_range(0.0, 2.0) var position_disperse : float = 2.0

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

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout # TODO: this has a potential to go VERY sour. replace with something better later
	_populate_multimesh()
	await get_tree().create_timer(0.5).timeout
	_translate_multimesh()

	leaf_cleaning_handler.on_cleaning_request_at_global_position.connect(_on_clean_origin_position_updated)

func _populate_multimesh() -> void:
	#get our multimesh
	multimesh = target_multimesh_instance.multimesh

	#get all non-black pixels in our noise texture
	# 0 - no leaf, 1 - leaf
	var viewport_texture = target_sub_viewport.get_texture()
	var image_data = viewport_texture.get_image()

	viewport_image_size = image_data.get_size()

	var suitable_pixels_count : int = 0
	var final_instances_count : int = 0

	for i in viewport_image_size.x:
		for j in viewport_image_size.y:
			if (image_data.get_pixel(j, i).r > 0.01):
				suitable_pixels_count += 1
				var leaves_count = floor(leaves_per_pixel * image_data.get_pixel(j, i).r)
				final_instances_count += leaves_count
				white_pixels.append(Vector2(j, i))

				var leaf_data = LeafInstanceData.create(Vector2i(j, i))
				leaf_data.index_count = leaves_count
				leaf_data_array.append(leaf_data)

	multimesh.instance_count = final_instances_count

func _translate_multimesh() -> void:
	print(multimesh.instance_count)

	var offset : int = 0

	for u in range(len(white_pixels)):
		var data = leaf_data_array[u]

		for v in (range(data.index_count)):
			var origin = Vector3(white_pixels[u].x - pixel_offset + (randf() - 0.5) * position_disperse, 1, white_pixels[u].y - pixel_offset + (randf() - 0.5) * position_disperse)
			var transform = Transform3D()
			transform = transform.rotated(Vector3.UP, randf() * PI * 2)
			transform = transform.translated(origin)
			multimesh.set_instance_transform(offset, transform)

			data.indexes.append(offset)

			offset += 1
	
	is_populated = true

func _on_clean_origin_position_updated(global_position : Vector3, cleaning_radius : int) -> void:
	var viewport_position = Vector2i(int(global_position.x + pixel_offset), int(global_position.z + pixel_offset))

	if (current_cleaning_position == viewport_position):
		return

	current_cleaning_position = viewport_position
	var circle = CircleUtils.get_circle_vector_array(viewport_position, cleaning_radius)

	for pos in circle:
		_clean_on_viewport_position(pos)
		print(pos)

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