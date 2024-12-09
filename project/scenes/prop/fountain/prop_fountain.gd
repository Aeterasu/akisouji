extends Node3D

@export var water_mesh : MeshInstance3D = null
@export var water_speed : float = 1.0 

@export var floating_leaves : Node3D = null
@export var leaves_speed : float = 0.1

var material : StandardMaterial3D = null

func _ready() -> void:
	material = water_mesh.get_surface_override_material(0) as StandardMaterial3D

func _physics_process(delta):
	material.uv1_offset += Vector3(0.15, 1.0, 0.0) * water_speed * delta

	floating_leaves.rotation_degrees += Vector3.UP * delta * leaves_speed