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

var leaf_chunk_data_array : Array[LeafChunkData] = []

var leaf_instances_sorted_by_position : Array[LeafInstanceData] = []
var leaf_instances_sorted_positions : Array[Vector2] = []

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

		for v in (range(data.index_count)):
			var origin = Vector3(white_pixels[u].x - pixel_offset + (randf() - 0.5) * position_disperse, 1, white_pixels[u].y - pixel_offset + (randf() - 0.5) * position_disperse)
			var transform = Transform3D()
			transform = transform.rotated(Vector3.UP, randf() * PI * 2)
			transform = transform.translated(origin)
			multimesh.set_instance_transform(offset, transform)

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

func _clean_leaf(index : int):
	var transform = Transform3D()
	transform.origin = Vector3(999, 999, 999)

	multimesh.set_instance_transform(index, transform)

func _clean_on_viewport_position(viewport_position : Vector2i, coeff : float = 1.0) -> void:
	for leaf_chunk_data in leaf_chunk_data_array:
		if (leaf_chunk_data.viewport_position == viewport_position):
			var target_indexes : int = int(ceil(len(leaf_chunk_data.indexes) * coeff))
			for i in range(leaf_chunk_data.last_clean_index, min(leaf_chunk_data.last_clean_index + target_indexes, leaf_chunk_data.indexes[0] + len(leaf_chunk_data.indexes))):
				_clean_leaf(i)
				leaf_chunk_data.last_clean_index = i
			return

# TODO: optimize with binary search
# TODO: real gradient circle
func _clean_on_real_position(real_position : Vector2, circle_radius : float = 1.0):
	var first_suitable_index : int = leaf_instances_sorted_positions.bsearch(real_position + Vector2.LEFT * circle_radius)

	for i in range(first_suitable_index, len(leaf_instances_sorted_by_position) - 1):
		var leaf = leaf_instances_sorted_by_position[i]
		var position = leaf.instance_position
		var distance = real_position.distance_to(position)

		if (distance <= circle_radius):
			var chance = 1.0
			var threshold = 0.5
			if (distance > threshold):
				chance = 1 - (distance / (circle_radius + threshold))
			
			if (randf() <= chance):
				_clean_leaf(leaf.instance_index)