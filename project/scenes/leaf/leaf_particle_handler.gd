class_name LeafParticleHandler extends Node

@export var particles : GPUParticles3D = null

func _on_leaves_cleaned(amount : int, scale : float = 1.0) -> void:
	if (amount <= 0):
		return

	amount = clamp(amount / 3, 1, 96)

	var node = particles.duplicate() as GPUParticles3D
	Game.game_instance.add_child(node)
	node.global_position = Game.game_instance.last_cleaning_position
	node.amount = amount
	(node.process_material as ParticleProcessMaterial).emission_shape_scale = Vector3(1.0, 0.1, 1.0) * Game.game_instance.last_cleaning_radius
	node.emitting = true

func _on_leaves_cleaned_at_position(amount : int, scale : float = 1.0, position : Vector3 = Vector3.ZERO) -> void:
	if (amount <= 0):
		return

	amount = clamp(amount, 1, 96)

	var node = particles.duplicate() as GPUParticles3D
	Game.game_instance.add_child(node)
	node.global_position = position
	node.amount = amount
	(node.process_material as ParticleProcessMaterial).emission_shape_scale = Vector3(1.0, 0.1, 1.0) * Game.game_instance.last_cleaning_radius
	node.emitting = true