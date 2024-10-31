class_name Level extends Node3D

@export var leaf_populator : LeafPopulator = null
@export var player_spawn_position : Marker3D = null

signal on_level_completion

func _on_completion_signal_received() -> void:
    on_level_completion.emit()