extends Node3D

@export var water_mesh : MeshInstance3D = null
@export var water_speed : float = 1.0 

@export var floating_leaves : Node3D = null
@export var leaves_speed : float = 0.1

@export var water : Area3D = null

var material : StandardMaterial3D = null

func _ready() -> void:
	material = water_mesh.get_surface_override_material(0) as StandardMaterial3D

	water.body_entered.connect(_on_water_body_entered)
	water.body_exited.connect(_on_water_body_exited)

func _physics_process(delta):
	material.uv1_offset += Vector3(0.15, 1.0, 0.0) * water_speed * delta

	floating_leaves.rotation_degrees += Vector3.UP * delta * leaves_speed

func _on_water_body_entered(body : Node3D):
	if (body is not Player):
		return

	(body as Player).footstep_manager.is_in_water = true

func _on_water_body_exited(body : Node3D):
	if (body is not Player):
		return

	(body as Player).footstep_manager.is_in_water = false