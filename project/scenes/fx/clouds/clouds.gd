extends MeshInstance3D

@export var direction : Vector3 = Vector3.DOWN * 0.05

var material : StandardMaterial3D = null

func _ready():
	material = mesh.surface_get_material(0) as StandardMaterial3D

func _physics_process(delta):
	material.uv1_offset += direction * delta