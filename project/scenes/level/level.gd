@tool class_name Level extends Node3D

@export var leaf_populator : LeafPopulator = null
@export_range(1, 5000) var leaf_leeway : int = 1
@export var player_spawn_position : Marker3D = null
@export var enable_rain : bool = false

@export var cash_reward : float = 1000.0:
    set(value):
        if (value < 0.0):
            value = 1.0

        cash_reward = value

@export var s_rank_target_score : float = 500000.0
@export var a_rank_target_score : float = 250000.0
@export var b_rank_target_score : float = 150000.0
@export var c_rank_target_score : float = 50000.0

@export var s_target_speed_clear : float = 250.0
@export var a_target_speed_clear : float = 500.0
@export var b_target_speed_clear : float = 1000.0

signal on_level_completion

func _on_completion_signal_received() -> void:
    on_level_completion.emit()