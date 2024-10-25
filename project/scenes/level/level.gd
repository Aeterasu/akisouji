class_name Level extends Node3D

@export var leaf_population : LeafPopulation = null
@export var player_spawn_position : Marker3D = null

var leaf_cleaning_handler : LeafCleaningHandler = null

signal on_level_completion

func _ready() -> void:
    if (!is_instance_valid(leaf_population)):
        return

    leaf_cleaning_handler = leaf_population.leaf_cleaning_handler
    leaf_cleaning_handler.on_completion.connect(_on_completion_signal_received)

func _on_completion_signal_received() -> void:
    on_level_completion.emit()