extends Area3D

@export var audio : AudioStreamPlayer3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node3D) -> void:
	if (body is GarbageBag):
		Game.game_instance.garbage_bag_progress_tracker._dispose_bag()
		audio.play()

		Game.game_instance.particle_handler._on_leaves_cleaned_at_position(48, 1.0, body.global_position + Vector3.DOWN)

		body.queue_free()