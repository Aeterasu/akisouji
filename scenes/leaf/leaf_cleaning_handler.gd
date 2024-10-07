class_name LeafCleaningHandler extends Node

signal on_cleaning_request_at_global_position

@export var base_cleaning_coeff : float = 0.8
@export var falloff_threshold : float = 0.2

var leaves_amount : int = 0
var cleaned_leaves_amount : int = 0

func _ready():
	_update_cleaned_leaves_progress()

func _on_player_cleaning_input(circle_radius : float = 1.0, cleaning_range : float = 64.0) -> void:
	var screen_size = get_viewport().size
	var screen_center = Vector2(screen_size.x * 0.5, screen_size.y * 0.5)

	var active_camera = get_viewport().get_camera_3d()
	var space_state = active_camera.get_world_3d().direct_space_state
	var from = active_camera.project_ray_origin(screen_center)
	var to = from + active_camera.project_ray_normal(screen_center) * cleaning_range
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	var result = space_state.intersect_ray(query)

	if (result):
		on_cleaning_request_at_global_position.emit(result["position"], circle_radius)

func _on_player_cleaning_on_position(position : Vector3, circle_radius : float = 1.0):
	on_cleaning_request_at_global_position.emit(position, circle_radius)

func _update_cleaned_leaves_progress() -> void:
	var ui = UI._get_ui()

	if (ui and ui.progress):
		ui.progress.max_value = leaves_amount
		ui.progress.current_value = cleaned_leaves_amount 	