class_name LeafPopulation extends Node

@export var enabled : bool = true

@export var leaves_per_pixel : int = 4
@export_range(0.0, 2.0) var position_disperse : float = 2.0

@export var target_multimesh_instance : MultiMeshInstance3D = null
@export var leafmap_resolution_fraction : float = 1.0
@export var pixel_offset : Vector2 = Vector2()
@export var target_leaf_map : Sprite2D = null
@export var height_map : Sprite2D = null

@export var leaf_cleaning_handler : LeafCleaningHandler = null

@export var leaf_color_palette : LeafColorPalette = null

@export var leaf_particle_manager : LeafParticleManager = null

var multimesh : MultiMesh = null

var viewport_image_size = Vector2i()
var white_pixels : Array[Vector2]

var leaf_chunk_data_array : Array[LeafChunkData] = []

var leaf_instances_sorted_by_position : Array[LeafInstanceData] = []
var leaf_instances_sorted_positions : Array[Vector2] = []
var cleaned_leaves : Array[bool] = []

var scale_interpolate_list : Array[int] = [] # list of leaf instances in need of scale-lerping!
var interpolation_deletion_queue : Array[int] = []

#TODO: Separate multimeshinstances into multiple clusters (amount of cluster should be configurable)
#TODO: Leaf population via navmesh
func _ready() -> void:
	if (!enabled):
		await get_tree().create_timer(0.1).timeout
		Game.game_instance._on_loading_ended()
		return

	await get_tree().create_timer(0.1).timeout # TODO: this has a potential to go VERY sour. replace with something better later
	_populate_multimesh()
	await get_tree().create_timer(0.1).timeout
	_translate_multimesh()
	Game.game_instance._on_loading_ended()

	leaf_cleaning_handler.leaves_amount = int(round(len(cleaned_leaves) * leaf_cleaning_handler.target_cleaned_amount_leeway))
	leaf_cleaning_handler.on_cleaning_request_at_global_position.connect(_on_clean_origin_position_updated)

func _physics_process(delta):
	if (len(scale_interpolate_list) > 0):
		for i in range(len(scale_interpolate_list)):
			var transform = multimesh.get_instance_transform(scale_interpolate_list[i])

			var scale = transform.basis.get_scale()

			if (scale.length() <= 0.1):
				multimesh.set_instance_transform(scale_interpolate_list[i], Transform3D.IDENTITY.scaled(Vector3.ZERO))
				interpolation_deletion_queue.append(i)
				continue

			scale = scale.lerp(Vector3.ZERO, 8 * delta)

			transform = transform.scaled_local(scale)
			multimesh.set_instance_transform(scale_interpolate_list[i], transform)

	if (len(interpolation_deletion_queue) > 0):
		var offset : int = 0
		for i in interpolation_deletion_queue:
			scale_interpolate_list.remove_at(i - offset)
			offset += 1
		interpolation_deletion_queue.clear()

func _populate_multimesh() -> void:
	#get our multimesh
	multimesh = target_multimesh_instance.multimesh

	#get all non-black pixels in our noise texture
	# 0 - no leaf, 1 - leaf
	var leafmap_texture = target_leaf_map.get_texture()
	var image_data = leafmap_texture.get_image()

	viewport_image_size = image_data.get_size()

	var suitable_pixels_count : int = 0
	var final_instances_count : int = 0

	Output.print("Leafmap texture size: " + str(viewport_image_size))

	for i in viewport_image_size.x:
		for j in viewport_image_size.y:
			if (image_data.get_pixel(i, j).r > 0.01):
				suitable_pixels_count += 1
				var leaves_count = floor(leaves_per_pixel * image_data.get_pixel(i, j).r)
				final_instances_count += leaves_count
				white_pixels.append(Vector2(i, j))

				var leaf_data = LeafChunkData.create(Vector2i(i, j))
				leaf_data.index_count = leaves_count
				leaf_chunk_data_array.append(leaf_data)

	Output.print("Suitable pixels for leaf population: " + str(suitable_pixels_count) + ", with the max of " + str(leaves_per_pixel) + " leaves per pixel")

	multimesh.instance_count = final_instances_count

func _translate_multimesh() -> void:
	Output.print("Leaf instances: " + str(multimesh.instance_count) + ", average " + str(float(multimesh.instance_count) / float((viewport_image_size.x * viewport_image_size.y))) + " leaves per pixel")

	var heightmap_texture = height_map.get_texture()
	var heightmap_image_data = heightmap_texture.get_image()	

	var offset : int = 0

	for u in len(white_pixels):
		var data = leaf_chunk_data_array[u]
		data.last_clean_index = offset

		for v in data.index_count:
			var position_x = clampf((white_pixels[u].x + pixel_offset.x + (randf() - 0.5) * position_disperse) / leafmap_resolution_fraction, 0.0, (viewport_image_size.x / leafmap_resolution_fraction) + pixel_offset.x)
			var position_y = clampf((white_pixels[u].y + pixel_offset.y + (randf() - 0.5) * position_disperse) / leafmap_resolution_fraction, 0.0, (viewport_image_size.y / leafmap_resolution_fraction) + pixel_offset.y)
			var height : float = 0.01
			height += float(heightmap_image_data.get_pixel(int(white_pixels[u].x), int(white_pixels[u].y)).r8) * 0.01

			var origin = Vector3(position_x, height, position_y)
			var transform = Transform3D()
			transform = transform.rotated(Vector3.UP, randf() * PI * 2)
			transform = transform.translated(origin)
			multimesh.set_instance_transform(offset, transform)
			multimesh.set_instance_color(offset, leaf_color_palette._get_random_color())

			cleaned_leaves.append(false)

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
	_clean_on_real_position(global_position, circle_radius)

func _clean_leaf(index : int, sorted_index : int):
	#var transform = Transform3D()
	#transform.origin = Vector3(0, 0, 0)

	#multimesh.set_instance_transform(index, transform)

	cleaned_leaves[index] = true
	leaf_cleaning_handler.cleaned_leaves_amount += 1

	scale_interpolate_list.append(index)

	# grant reward

	CashManager._grant_cash()

	# update progress on ui

	leaf_cleaning_handler._update_cleaned_leaves_progress()

	#Output.print("Cleaned leaf at index " + str(index) + ", sorted index " + str(sorted_index))

# TODO: real gradient circle
func _clean_on_real_position(real_position : Vector3, circle_radius : float = 1.0):
	Output.print("Requested cleaning, real position: " + str(real_position) + ", cleaning radius: " + str(circle_radius))

	var real_position_2d = Vector2(real_position.x, real_position.z)
	var first_suitable_index : int = leaf_instances_sorted_positions.bsearch(real_position_2d + Vector2.LEFT * circle_radius)

	var cleaned_amount = 0

	var first_index = -1
	var last_index = 0

	for i in range(first_suitable_index, len(leaf_instances_sorted_by_position) - 1):
		var leaf = leaf_instances_sorted_by_position[i]
		var position = leaf.instance_position
		var distance = real_position_2d.distance_to(position)

		if (!cleaned_leaves[leaf.instance_index] && distance <= circle_radius):
			var chance = 1.0
			if (distance > leaf_cleaning_handler.falloff_threshold):
				chance = (1 - (distance / (circle_radius + leaf_cleaning_handler.falloff_threshold))) * leaf_cleaning_handler.base_cleaning_coeff
			
			if (randf() <= chance):
				if (first_index == -1):
					first_index = i

				_clean_leaf(leaf.instance_index, i)
				last_index = i
				cleaned_amount += 1
		elif (position >= real_position_2d + Vector2.ONE * circle_radius):
			break

	if (cleaned_amount / 2 > 0):
		leaf_particle_manager._create_particles_on_real_position(real_position, cleaned_amount / 2)

	Output.print("Cleaned " + str(cleaned_amount) + " leaves, in index range " + str(first_suitable_index) + " to " + str(last_index))