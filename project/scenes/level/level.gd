class_name Level extends Node3D

@export var leaf_populator : LeafPopulator = null
@export var player_spawn_position : Marker3D = null

signal on_level_completion

func _process(delta : float) -> void:
    if (UI.instance):
        if (leaf_populator and !UI.instance.progress.leaf_populator):
            UI.instance.progress.leaf_populator = leaf_populator

func _on_completion_signal_received() -> void:
    on_level_completion.emit()