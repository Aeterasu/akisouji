class_name LeafParticleHandler extends Node

@export var particles_scene : PackedScene = null

func _ready() -> void:
	var a = particles_scene.instantiate()
	add_child(a)
	a.queue_free()

func _on_leaves_cleaned(amount : int, scale : float = 1.0) -> void:
	if (amount <= 0):
		return

	amount = clamp(amount / 3, 1, 18)

	var node = particles_scene.instantiate() as GPUParticles3D
	node.amount = amount
	Game.game_instance.add_child(node)
	node.global_position = Game.game_instance.last_cleaning_position
	(node.process_material as ParticleProcessMaterial).emission_shape_scale *= scale
	node.emitting = true