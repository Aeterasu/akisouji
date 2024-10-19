extends Node

@export var master_volume : float = 1.0
@export var sfx_volume : float = 1.0
@export var ambience_volume : float = 1.0
@export var music_volume : float = 1.0

@export_range(0.01, 1.0) var mouse_sensitivity : float = 0.125:
    set(value):
        if (value < 0.01):
            value = 0.01
        elif (value > 1.0):
            value = 1.0

        mouse_sensitivity = value

@export_range(1.0, 256.0) var gamepad_sensitvity : float = 64.0
@export_range(0.0, 1.0) var gamepad_deadzone : float = 0.3

@export_range(70.0, 100.0) var fov : float = 75.0:
    set(value):
        if (value < 70.0):
            value = 70.0
        elif (value > 100.0):
            value = 100.0

        fov = value

@export var camera_wobble_enabled : bool = true

@export var show_fps_counter : bool = true