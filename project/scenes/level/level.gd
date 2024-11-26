@tool class_name Level extends Node3D

@export var leaf_populator : LeafPopulator = null
@export var player_spawn_position : Marker3D = null
@export var enable_rain : bool = false

@export var cash_reward : float = 1000.0:
    set(value):
        if (value < 0.0):
            value = 1.0

        cash_reward = value

@export var s_rank_target_time : float = 100.0:
    get():
        return s_rank_target_time
    set(value):
        if (value < 0.0):
            value = 0.0

        if (value > a_rank_target_time):
            value = a_rank_target_time

        s_rank_target_time = value

@export var a_rank_target_time : float = 250.0:
    get():
        return a_rank_target_time
    set(value):
        if (value < 0.0):
            value = 0.0

        if (value > b_rank_target_time):
            value = b_rank_target_time
        elif (value < s_rank_target_time):
            value = s_rank_target_time

        a_rank_target_time = value

@export var b_rank_target_time : float = 500.0:
    get():
        return b_rank_target_time
    set(value):
        if (value < 0.0):
            value = 0.0

        if (value < a_rank_target_time):
            value = a_rank_target_time
        elif (value > c_rank_target_time):
            value = c_rank_target_time

        b_rank_target_time = value

@export var c_rank_target_time : float = 750.0:
    get():
        return c_rank_target_time
    set(value):
        if (value < 0.0):
            value = 0.0

        if (value > d_rank_target_time):
            value = d_rank_target_time
        elif (value < b_rank_target_time):
            value = b_rank_target_time

        c_rank_target_time = value

@export var d_rank_target_time : float = 1000.0:
    get():
        return d_rank_target_time
    set(value):
        if (value < 0.0):
            value = 0.0

        if (value < c_rank_target_time):
            value = c_rank_target_time

        d_rank_target_time = value

signal on_level_completion

func _on_completion_signal_received() -> void:
    on_level_completion.emit()