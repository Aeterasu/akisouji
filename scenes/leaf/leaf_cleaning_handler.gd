class_name LeafCleaningHandler extends Node

signal on_cleaning_request_at_global_position

@export var base_cleaning_coeff : float = 0.8
@export var falloff_threshold : float = 0.2

#TODO: add overload for on-the-fly generated circles, but later
func _on_player_cleaning_input(circle_radius : float = 1.0) -> void:
	var screen_size = get_viewport().size
	var screen_center = Vector2(screen_size.x * 0.5, screen_size.y * 0.5)

	var active_camera = get_viewport().get_camera_3d()
	var space_state = active_camera.get_world_3d().direct_space_state
	var from = active_camera.project_ray_origin(screen_center)
	var to = from + active_camera.project_ray_normal(screen_center) * 64.0
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	var result = space_state.intersect_ray(query)

	if (result):
		on_cleaning_request_at_global_position.emit(result["position"], circle_radius)