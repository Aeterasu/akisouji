extends Node

@export var enabled : bool = true

@export var leaves_per_pixel : int = 4
@export_range(0.0, 2.0) var position_disperse : float = 2.0

@export var target_multimesh_instance : MultiMeshInstance3D = null
@export var target_sub_viewport : SubViewport = null

@export var leaf_cleaning_handler : LeafCleaningHandler = null

@export var leaf_color_palette : LeafColorPalette = null

var multimesh : MultiMesh = null

var viewport_image_size = Vector2i()
var white_pixels : Array[Vector2]

var pixel_offset : int = 0

var leaf_chunk_data_array : Array[LeafChunkData] = []

var leaf_instances_sorted_by_position : Array[LeafInstanceData] = []
var leaf_instances_sorted_positions : Array[Vector2] = []

func _ready() -> void:
	if (!enabled):
		return

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

				var leaf_data = LeafChunkData.create(Vector2i(j, i))
				leaf_data.index_count = leaves_count
				leaf_chunk_data_array.append(leaf_data)

	multimesh.instance_count = final_instances_count

func _translate_multimesh() -> void:
	print("Instances: " + str(multimesh.instance_count))

	var offset : int = 0

	for u in range(len(white_pixels)):
		var data = leaf_chunk_data_array[u]
		data.last_clean_index = offset

		# TODO: tie leaves' z position to a heightmap. use 255 colors with 0.1 step
		for v in (range(data.index_count)):
			var position_x = clampf(white_pixels[u].x - pixel_offset + (randf() - 0.5) * position_disperse, 0.0, viewport_image_size.x)
			var position_y = clampf(white_pixels[u].y - pixel_offset + (randf() - 0.5) * position_disperse, 0.0, viewport_image_size.y)
			var origin = Vector3(position_x, 0.05, position_y)
			var transform = Transform3D()
			transform = transform.rotated(Vector3.UP, randf() * PI * 2)
			transform = transform.translated(origin)
			multimesh.set_instance_transform(offset, transform)
			multimesh.set_instance_color(offset, leaf_color_palette._get_random_color())

			data.indexes.append(offset)

			leaf_instances_sorted_by_position.append(LeafInstanceData.create(Vector2(origin.x, origin.z), offset))

			offset += 1

	leaf_instances_sorted_by_position.sort_custom(sort_leaf_instances_by_position)

	for leaf in leaf_instances_sorted_by_position:
		leaf_instances_sorted_positions.append(leaf.instance_position)

func sort_leaf_instances_by_position(a : LeafInstanceData, b : LeafInstanceData) -> bool:
	if (a.instance_position < b.instance_position):
		return true
	return false
			
func _on_clean_origin_position_updated(global_position : Vector3, circle_radius : float = 1.0) -> void:
	_clean_on_real_position(Vector2(global_position.x, global_position.z), circle_radius)

func _clean_leaf(index : int, sorted_index : int):
	var transform = Transform3D()
	transform.origin = Vector3(999, 999, 999)

	multimesh.set_instance_transform(index, transform)

# TODO: real gradient circle
func _clean_on_real_position(real_position : Vector2, circle_radius : float = 1.0):
	var first_suitable_index : int = leaf_instances_sorted_positions.bsearch(real_position + Vector2.LEFT * circle_radius)

	for i in range(first_suitable_index, len(leaf_instances_sorted_by_position) - 1):
		var leaf = leaf_instances_sorted_by_position[i]
		var position = leaf.instance_position
		var distance = real_position.distance_to(position)

		if (distance <= circle_radius):
			var chance = 1.0
			if (distance > leaf_cleaning_handler.falloff_threshold):
				chance = (1 - (distance / (circle_radius + leaf_cleaning_handler.falloff_threshold))) * leaf_cleaning_handler.base_cleaning_coeff
			
			if (randf() <= chance):
				_clean_leaf(leaf.instance_index, i)
		elif (position >= real_position + Vector2.ONE * circle_radius):
			break