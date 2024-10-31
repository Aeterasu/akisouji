extends GPUParticles3D

@export var map_size : Vector3 = Vector3()

var material : ShaderMaterial = null

func _ready():
	material = process_material as ShaderMaterial
	material.set_shader_parameter("emission_box_extents", map_size)
	emitting = true