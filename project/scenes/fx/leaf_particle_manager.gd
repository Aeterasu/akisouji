class_name LeafParticleManager extends Node

@export_group("Visuals")
@export var leaf_particles : PackedScene = null

func _create_particles_on_real_position(position : Vector3, amount : int):
	if (leaf_particles):
		var particle_node = leaf_particles.instantiate() as GPUParticles3D
		add_child(particle_node)
		particle_node.one_shot = true
		particle_node.amount = amount
		particle_node.global_position = position
		particle_node.set_deferred("emitting", true)